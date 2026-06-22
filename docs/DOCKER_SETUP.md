# Hướng Dẫn Cài Đặt và Chạy Docker Cho Dự Án AI Study Hub

Tài liệu này hướng dẫn cách clone source code và thiết lập Docker cho dự án từ đầu, đảm bảo không gặp các lỗi liên quan đến thiếu file hay biến môi trường.

## 1. Yêu cầu hệ thống

Trước khi bắt đầu, hãy đảm bảo máy tính của bạn đã cài đặt các phần mềm sau:
- **Git** (để clone dự án)
- **Docker Desktop** (hoặc Docker Engine & Docker Compose)

## 2. Các Bước Cài Đặt Chi Tiết

### Bước 2.1: Clone dự án về máy

Mở Terminal / Command Prompt và chạy lệnh sau:

```bash
git clone https://github.com/SWP391-SU26-SE1923-GROUP5/dev-swagger-docker.git
cd dev-swagger-docker
```

### Bước 2.2: Tạo file cấu hình môi trường (.env và appsettings)

Vì lý do bảo mật, các file chứa key (như `.env` hay `appsettings.json`) không được đưa lên GitHub. Bạn **bắt buộc phải tự tạo** chúng từ các file mẫu đã có sẵn. 

**Tạo file `.env` (Dùng cho Docker):**
File `.env` cung cấp các biến môi trường cho quá trình chạy `docker-compose`. Nếu thiếu file này, bạn sẽ nhận được một loạt cảnh báo biến bị trống (*variable is not set*) ở Terminal.

Windows (PowerShell/CMD):
```bash
copy .env.example .env
```
Linux/macOS:
```bash
cp .env.example .env
```
*Lưu ý: Bạn có thể mở file `.env` vừa tạo để điền các thông tin như `SMTP`, `CLOUDINARY`,... nếu cần.*

**Tạo file `appsettings.json` (Dùng cho code C#):**
Windows (PowerShell/CMD):
```bash
copy AIStudyHub.API\appsettings.example.json AIStudyHub.API\appsettings.json
```
Linux/macOS:
```bash
cp AIStudyHub.API/appsettings.example.json AIStudyHub.API/appsettings.json
```

### Bước 2.3: Build và khởi chạy Docker

Đây là bước quan trọng. Mặc định `docker-compose up -d` có thể sẽ dùng lại image cũ đã được build trước đó. Khi có code mới pull từ GitHub về, bạn **phải thêm cờ `--build`** để Docker build lại ứng dụng.

```bash
docker-compose up -d --build
```

Lệnh này sẽ:
1. Kéo (pull) image của SQL Server và Qdrant (Vector Database).
2. Build code C# thành file chạy và đóng gói vào image của API.
3. Chạy các container ở chế độ ngầm (`-d`).

---

## 3. Các Lỗi Thường Gặp & Cách Xử Lý

### Lỗi 1: `variable is not set. Defaulting to a blank string.`
**Nguyên nhân:** Thiếu file `.env` ở thư mục gốc chứa `docker-compose.yml`.
**Cách khắc phục:** Làm lại Bước 2.2 để copy `.env.example` sang `.env`.

### Lỗi 2: `The type or namespace name 'XYZ' could not be found (CS0246)`
**Nguyên nhân:** Đây là lỗi do bản build của Docker đang bị cũ, không ăn khớp với code mới nhất, hoặc do dự án chưa lấy đủ code mới về.
**Cách khắc phục:** 
- Bước 1: Kéo code mới nhất về bằng lệnh `git pull`.
- Bước 2: Build lại Docker image một cách tường minh để đảm bảo nó lấy code mới nhất:
  ```bash
  docker-compose build --no-cache
  docker-compose up -d
  ```

### Lỗi 3: Ứng dụng thoát đột ngột, lỗi kết nối SQL Server
**Nguyên nhân:** Container của DB chưa kịp khởi động xong, hoặc cấu hình `MSSQL_SA_PASSWORD` trong file `.env` không đủ độ khó (SQL Server yêu cầu mật khẩu phải chứa chữ hoa, chữ thường, số và ký tự đặc biệt).
**Cách khắc phục:**
1. Kiểm tra lại mật khẩu `MSSQL_SA_PASSWORD` trong file `.env`. (Mặc định trong file example đang là `StrongPassword123!` là đã đủ an toàn).
2. Kiểm tra log của DB xem lỗi gì bằng lệnh: `docker logs aistudyhub-db`.

### Lỗi 4: Xung đột Port (Cổng)
**Nguyên nhân:** Cổng `5171` (API) hoặc `1433` (SQL Server) đang bị một ứng dụng khác trên máy bạn sử dụng.
**Cách khắc phục:** Mở file `docker-compose.yml` và đổi cổng bên trái của mục `ports:`.
Ví dụ: Đổi `"5171:8080"` thành `"6171:8080"`.

---

## 4. Các Câu Lệnh Hữu Ích Khác

- **Xem trạng thái các container:**
  ```bash
  docker-compose ps
  ```

- **Tắt hệ thống (nhưng giữ nguyên dữ liệu trong Database):**
  ```bash
  docker-compose down
  ```

- **Tắt hệ thống VÀ xóa trắng dữ liệu Database (Reset):**
  ```bash
  docker-compose down -v
  ```

- **Xem log của API:**
  ```bash
  docker logs aistudyhub-api -f
  ```
