const mysql = require('mysql2');

// สร้างการเชื่อมต่อกับฐานข้อมูล
const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',      // XAMPP ปกติใช้ root
    password: '',      // XAMPP ปกติรหัสผ่านจะว่าง
    database: 'zetzero_db'
});

connection.connect((err) => {
    if (err) {
        console.error('เกิดข้อผิดพลาดในการเชื่อมต่อฐานข้อมูล:', err);
        return;
    }
    console.log('เชื่อมต่อฐานข้อมูล MySQL สำเร็จ!');
});

module.exports = connection;
