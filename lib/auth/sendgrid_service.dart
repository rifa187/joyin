import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <--- TAMBAHAN IMPORT

class SendGridService {
  // --- KONFIGURASI ---
  // API Key diambil dari file .env (tanpa tanda kutip)
  final String _apiKey = dotenv.env['SENDGRID_API_KEY'] ?? ''; 
  
  // Email ini WAJIB berstatus VERIFIED di SendGrid (Sender Authentication)
  final String _senderEmail = 'bejoyinin@gmail.com'; 
  // -------------------

  Future<bool> sendOtpEmail(String userEmail, String otpCode) async {
    final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');

    // Membuat Body Email (Format JSON)
    final Map<String, dynamic> body = {
      "personalizations": [
        {
          "to": [
            {"email": userEmail}
          ],
          "subject": "Kode Verifikasi JOYIN: $otpCode"
        }
      ],
      "from": {
        "email": _senderEmail,
        "name": "JOYIN App"
      },
      "content": [
        {
          "type": "text/html",
          "value": """
            <div style="font-family: Helvetica, Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #eeeeee; border-radius: 8px;">
              <h2 style="color: #2c3e50; text-align: center;">Verifikasi Akun JOYIN</h2>
              <p style="font-size: 16px; color: #555;">Halo,</p>
              <p style="font-size: 16px; color: #555;">Terima kasih telah mendaftar. Gunakan kode berikut untuk menyelesaikan pendaftaran Anda:</p>
              
              <div style="text-align: center; margin: 30px 0;">
                <span style="font-size: 32px; font-weight: bold; color: #ffffff; background-color: #007BFF; padding: 15px 30px; letter-spacing: 5px; border-radius: 8px;">$otpCode</span>
              </div>
              
              <p style="font-size: 14px; color: #999; text-align: center;">Kode ini berlaku selama 5 menit. Jangan berikan kepada siapapun.</p>
              <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
              <p style="font-size: 12px; color: #aaa; text-align: center;">&copy; 2025 JOYIN App Team</p>
            </div>
          """
        }
      ]
    };

    try {
      final response = await http.post(
        url,
        headers: {
          // PENTING: API Key sekarang diambil dari variabel yang di-load dari .env
          'Authorization': 'Bearer $_apiKey', 
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      // --- LOGIKA PENGECEKAN STATUS ---
      if (response.statusCode == 202) {
        debugPrint("✅ SENDGRID: Email berhasil dikirim ke $userEmail");
        return true;
      } else {
        // Log Error Lengkap agar ketahuan salahnya dimana
        debugPrint("❌ SENDGRID GAGAL (Status: ${response.statusCode})");
        debugPrint("❌ PESAN ERROR: ${response.body}");

        if (response.statusCode == 401) {
          debugPrint("👉 SOLUSI: API Key salah atau hangus. Cek Settings > API Keys.");
        } else if (response.statusCode == 403) {
          debugPrint("👉 SOLUSI: Sender Identity ($_senderEmail) belum diverifikasi.");
        }
        
        return false;
      }
    } catch (e) {
      debugPrint("❌ SENDGRID ERROR KONEKSI: $e");
      return false;
    }
  }
}