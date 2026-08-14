const express = require('express');
const cors = require('cors');
const bcrypt = require('bcrypt');
const db = require('./db');

const app = express();
const PORT = 3000;

// ให้ Express อ่านข้อมูลแบบ JSON
app.use(express.json());
// อนุญาตให้แอปพลิเคชัน Flutter เรียกใช้ API ได้
app.use(cors());

// 1. API สำหรับสมัครสมาชิก (Register)
app.post('/register', async (req, res) => {
    const { username, email, password } = req.body;

    // ตรวจสอบว่าใส่ข้อมูลครบไหม
    if (!username || !email || !password) {
        return res.status(400).json({ message: 'กรุณากรอกข้อมูลให้ครบถ้วน' });
    }

    try {
        // เข้ารหัสผ่านก่อนบันทึกลงฐานข้อมูลเพื่อความปลอดภัย
        const hashedPassword = await bcrypt.hash(password, 10);

        // คำสั่ง SQL เพิ่มข้อมูล
        const sql = 'INSERT INTO users (username, email, password) VALUES (?, ?, ?)';
        
        db.query(sql, [username, email, hashedPassword], (err, result) => {
            if (err) {
                if (err.code === 'ER_DUP_ENTRY') {
                    return res.status(400).json({ message: 'ชื่อผู้ใช้หรืออีเมลนี้มีในระบบแล้ว' });
                }
                console.error(err);
                return res.status(500).json({ message: 'เกิดข้อผิดพลาดในการบันทึกข้อมูล' });
            }
            res.status(201).json({ message: 'สมัครสมาชิกสำเร็จ!' });
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'เกิดข้อผิดพลาดของเซิร์ฟเวอร์' });
    }
});

// 2. API สำหรับเข้าสู่ระบบ (Login)
app.post('/login', (req, res) => {
    const { username, password } = req.body;

    if (!username || !password) {
        return res.status(400).json({ message: 'กรุณากรอกชื่อผู้ใช้และรหัสผ่าน' });
    }

    // ค้นหาผู้ใช้ในฐานข้อมูล
    const sql = 'SELECT * FROM users WHERE username = ?';
    db.query(sql, [username], async (err, results) => {
        if (err) {
            console.error(err);
            return res.status(500).json({ message: 'เกิดข้อผิดพลาดในการดึงข้อมูล' });
        }

        if (results.length === 0) {
            return res.status(401).json({ message: 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง' });
        }

        const user = results[0];

        // เทียบรหัสผ่านที่ส่งมา กับที่เข้ารหัสไว้ในฐานข้อมูล
        const isMatch = await bcrypt.compare(password, user.password);

        if (!isMatch) {
            return res.status(401).json({ message: 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง' });
        }

        res.status(200).json({ 
            message: 'เข้าสู่ระบบสำเร็จ!',
            user: { id: user.id, username: user.username, email: user.email }
        });
    });
});

// 3. API ขอรหัสกู้คืน (Forgot Password)
app.post('/forgot-password', (req, res) => {
    const { email } = req.body;
    if (!email) return res.status(400).json({ message: 'กรุณากรอกอีเมล' });

    // สร้างรหัส 6 หลักแบบสุ่ม
    const code = Math.floor(100000 + Math.random() * 900000).toString();

    const sql = 'UPDATE users SET reset_code = ? WHERE email = ?';
    db.query(sql, [code, email], (err, result) => {
        if (err) return res.status(500).json({ message: 'เกิดข้อผิดพลาดของเซิร์ฟเวอร์' });
        
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'ไม่พบอีเมลนี้ในระบบ' });
        }
        
        // ในระบบจริงต้องส่งอีเมลตรงนี้ แต่เราจำลองว่าส่งสำเร็จและคืนค่ารหัสเพื่อการทดสอบ
        res.status(200).json({ message: 'รหัสยืนยันถูกส่งไปที่อีเมลของคุณแล้ว (จำลอง)', mock_code: code });
    });
});

// 4. API ยืนยันรหัส (Verify Code)
app.post('/verify-code', (req, res) => {
    const { email, code } = req.body;
    if (!email || !code) return res.status(400).json({ message: 'ข้อมูลไม่ครบถ้วน' });

    const sql = 'SELECT * FROM users WHERE email = ? AND reset_code = ?';
    db.query(sql, [email, code], (err, results) => {
        if (err) return res.status(500).json({ message: 'เกิดข้อผิดพลาด' });
        if (results.length === 0) return res.status(400).json({ message: 'รหัสยืนยันไม่ถูกต้อง' });
        
        res.status(200).json({ message: 'รหัสถูกต้อง' });
    });
});

// 5. API เปลี่ยนรหัสผ่านใหม่ (Reset Password)
app.post('/reset-password', async (req, res) => {
    const { email, code, newPassword } = req.body;
    if (!email || !code || !newPassword) return res.status(400).json({ message: 'ข้อมูลไม่ครบถ้วน' });

    try {
        const hashedPassword = await bcrypt.hash(newPassword, 10);
        // เช็คอีกรอบเพื่อความปลอดภัย และลบ reset_code ทิ้ง
        const sql = 'UPDATE users SET password = ?, reset_code = NULL WHERE email = ? AND reset_code = ?';
        db.query(sql, [hashedPassword, email, code], (err, result) => {
            if (err) return res.status(500).json({ message: 'เกิดข้อผิดพลาด' });
            if (result.affectedRows === 0) return res.status(400).json({ message: 'รหัสยืนยันไม่ถูกต้องหรือถูกใช้ไปแล้ว' });
            
            res.status(200).json({ message: 'เปลี่ยนรหัสผ่านสำเร็จ!' });
        });
    } catch (error) {
        res.status(500).json({ message: 'เกิดข้อผิดพลาดของเซิร์ฟเวอร์' });
    }
});

// เริ่มรันเซิร์ฟเวอร์
app.listen(PORT, () => {
    console.log(`เซิร์ฟเวอร์ Backend รันอยู่ที่ http://localhost:${PORT}`);
});
