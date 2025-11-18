#ifndef seshat_bridge_h
#define seshat_bridge_h

#include <stdint.h> // Để dùng kiểu int8_t, uint32_t...

// --- Định nghĩa kiểu Opaque ---
// Obj-C/Swift sẽ không biết bên trong "SeshatDatabase" là gì,
// nó chỉ biết đây là một con trỏ.
typedef struct SeshatDatabase SeshatDatabase;


// --- 1. Quản lý Vòng đời ---

/**
 * Mở hoặc tạo một database Seshat tại đường dẫn `path`.
 * Database sẽ được mã hóa bằng mật khẩu `passphrase`.
 * @return Con trỏ tới database, hoặc NULL nếu thất bại.
 */
SeshatDatabase* seshat_database_open(const char* path, const char* passphrase);

/**
 * Đóng và giải phóng toàn bộ bộ nhớ của database.
 * Sau khi gọi hàm này, con trỏ `db` sẽ không còn hợp lệ.
 */
void seshat_database_close(SeshatDatabase* db);


// --- 2. Lập Chỉ mục (Indexing) ---

/**
 * Thêm một sự kiện vào chỉ mục.
 * @param db Con trỏ database.
 * @param event_json Một chuỗi JSON của MXEvent (ví dụ: event.jsonDictionary()).
 * @param profile_json Một chuỗi JSON của profile người gửi (tên, avatar).
 */
void seshat_database_add_event(SeshatDatabase* db, const char* event_json, const char* profile_json);


// --- 3. Tìm kiếm (Searching) ---

/**
 * Tìm kiếm trong database.
 * @return Một chuỗi JSON chứa mảng kết quả.
 * QUAN TRỌNG: Chuỗi trả về này phải được giải phóng (free)
 * bằng cách gọi `seshat_free_string` để tránh rò rỉ bộ nhớ.
 */
const char* seshat_database_search(SeshatDatabase* db, const char* query, const char* room_id);


// --- 4. Quản lý Bộ nhớ (Bắt buộc) ---

/**
 * Giải phóng một chuỗi được tạo ra từ Rust (ví dụ: kết quả của `seshat_database_search`).
 */
void seshat_free_string(const char* s);

#endif /* seshat_bridge_h */
