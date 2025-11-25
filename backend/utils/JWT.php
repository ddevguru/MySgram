<?php
require_once '../config/config.php';

class JWT {
    private static function base64url_encode($data) {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    private static function base64url_decode($data) {
        return base64_decode(strtr($data, '-_', '+/') . str_repeat('=', 3 - (3 + strlen($data)) % 4));
    }

    public static function generate($payload) {
        $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
        $payload = json_encode($payload);
        
        $base64UrlHeader = self::base64url_encode($header);
        $base64UrlPayload = self::base64url_encode($payload);
        
        $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, JWT_SECRET, true);
        $base64UrlSignature = self::base64url_encode($signature);
        
        return $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;
    }

    public static function verify($token) {
        $parts = explode('.', $token);
        
        if (count($parts) !== 3) {
            return false;
        }
        
        $header = $parts[0];
        $payload = $parts[1];
        $signature = $parts[2];
        
        $expectedSignature = self::base64url_encode(
            hash_hmac('sha256', $header . "." . $payload, JWT_SECRET, true)
        );
        
        if (!hash_equals($signature, $expectedSignature)) {
            return false;
        }
        
        $decodedPayload = json_decode(self::base64url_decode($payload), true);
        
        if ($decodedPayload === null) {
            return false;
        }
        
        // Check if token is expired
        if (isset($decodedPayload['exp']) && $decodedPayload['exp'] < time()) {
            return false;
        }
        
        return $decodedPayload;
    }

    public static function getUserIdFromToken($token) {
        $payload = self::verify($token);
        if ($payload && isset($payload['user_id'])) {
            return $payload['user_id'];
        }
        return null;
    }
}
?> 