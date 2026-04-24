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

        const prompt = "Đây là món ăn gì của Việt Nam? Phân tích và trả về JSON chuẩn gồm: dish_name (string), components (array of string), weight_g (number), calories (number).";

        const result = await model.generateContent([prompt, imagePart]);
        const response = await result.response;
        const text = response.text();

        console.log("✅ Phân tích thành công!");
        res.send(text);
    } catch (error) {
        console.error("❌ Lỗi:", error.message);
        res.status(500).json({ error: error.message });
    }
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`🚀 Demo đang sẵn sàng tại: http://localhost:${PORT}`);
});
