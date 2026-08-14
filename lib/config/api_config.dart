class ApiConfig {
  // หากต้องการนำแอปไป Build หรือเปิดให้คนอื่นใช้จริงๆ (Production)
  // ต้องเปลี่ยน URL ด้านล่างนี้เป็นโดเมนเนมของ Server ที่คุณเอา Backend ไปฝากไว้บนอินเทอร์เน็ต
  // เช่น 'https://my-zetzero-api.onrender.com'
  
  // สำหรับตอนพัฒนาและทดสอบในวง LAN เดียวกัน
  static const String baseUrl = 'http://172.30.133.186:3000';
}
