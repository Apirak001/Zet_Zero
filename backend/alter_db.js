const db = require('./db');

const alterTableQuery = "ALTER TABLE users ADD COLUMN reset_code VARCHAR(10) NULL;";

db.query(alterTableQuery, (err, result) => {
    if (err) {
        if (err.code === 'ER_DUP_FIELDNAME') {
            console.log("Column 'reset_code' already exists.");
        } else {
            console.error("Error altering table:", err);
        }
    } else {
        console.log("Successfully added 'reset_code' column to users table.");
    }
    db.end();
});
