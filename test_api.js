const express = require('express');
const multer = require('multer');
const { GoogleGenerativeAI } = require("@google/generative-ai");
const path = require('path');

const app = express();
const upload = multer();

// Phục vụ file giao diện Demo
app.use(express.static('public'));
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// 🔑 API Key của bạn đã được cấu hình
const API_KEY = "AIzaSyCJnnXMjemFjytBC3ubYuO3mp35fDF6deY";
const genAI = new GoogleGenerativeAI(API_KEY);

app.post('/analyze-food', upload.single('image'), async (req, res) => {
    console.log("📥 Nhận được yêu cầu phân tích ảnh...");
    try {
        if (!req.file) {
            return res.status(400).json({ error: "Vui lòng upload một file ảnh!" });
        }

        const model = genAI.getGenerativeModel({
            model: "gemini-3-flash-preview",
            generationConfig: { responseMimeType: "application/json" }
        });

        const imagePart = {
            inlineData: {
                data: req.file.buffer.toString("base64"),
                mimeType: req.file.mimetype
            }
        };
