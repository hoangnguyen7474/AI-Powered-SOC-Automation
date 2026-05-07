const body = items[0].json.body;
const result = body.result || {};  // Safe access

let extracted = {
  search_name: body.search_name || 'Unknown Alert',
  attack_type: result.attack_type || 'Unknown',
  severity: result.severity || 'Informational',
  ip_address: result.ip_address || result.Source_Address || result.SRC_IP || 'N/A',
  computer_name: result.ComputerName || result.Destination_Address || 'N/A',
  time: result._time || 'N/A',
  // Extract fields cụ thể theo loại tấn công
  attempts: result.attempts || 'N/A',  // Cho brute-force
  connection_count: result.connection_count || 'N/A',  // Cho DDoS
  message: result.Message || 'N/A',  // Cho malware PowerShell (full script nếu có)
  attack_type_cic: result.ATTACK_TYPE || 'N/A',  // Cho CIC-IDS legacy
  raw_details: JSON.stringify(result, null, 2)  // Giữ lại nếu cần debug, nhưng KHÔNG dùng chính trên Slack
};

const searchName = extracted.search_name || 'Unknown';
if (searchName.includes('SOC-AL-04')) {
  extracted.channel_name = '#alert-cic-ids';  // Chung cho tất cả SOC-AL-04, dù ATTACK_TYPE gì
} else if (searchName.includes('SOC-AL-01')) {
  extracted.channel_name = '#alert-brute-force';  // Riêng cho brute-force
} else if (searchName.includes('SOC-AL-02')) {
  extracted.channel_name = '#alert-malware';  // Riêng cho malware
} else if (searchName.includes('SOC-AL-03')) {
  extracted.channel_name = '#alert-ddos';  // Riêng cho DDoS
} else {
  extracted.channel_name = '#alert-general';  // Fallback chung
}

return [{ json: extracted }];