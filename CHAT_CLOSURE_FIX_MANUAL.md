# 🔧 إصلاح Closure في getConversations

## المشكلة:
في `app/Http/Controllers/Api/ChatController.php` line 67:

```php
->map(function ($conversation) {
    $participant = $conversation->participants->where('user_id', $normalizedUserId)->first();
    // ...
})
```

**الخطأ:** `$normalizedUserId` مستخدم داخل closure لكن مش متمرر عبر `use`!

## الحل:
**Line 67** يجب تعديله إلى:

```php
->map(function ($conversation) use ($normalizedUserId) {
    $participant = $conversation->participants->where('user_id', $normalizedUserId)->first();
    // ...
})
```

## التطبيق:
يمكن التعديل يدوياً عبر SSH:

```bash
ssh root@31.97.46.103
cd /var/www/erp1
nano app/Http/Controllers/Api/ChatController.php
# اذهب للسطر 67
# غير: ->map(function ($conversation) {
# إلى: ->map(function ($conversation) use ($normalizedUserId) {
# احفظ: Ctrl+O ثم Enter
# اخرج: Ctrl+X
php artisan cache:clear
php artisan route:clear
```
