<?php
require_once '../config/database.php';
require_once '../utils/JWT.php';

class TwilioService {
    private $accountSid;
    private $authToken;
    private $twilioNumber;
    private $baseUrl;
    
    public function __construct() {
        // Load from environment variables or config file
        $this->accountSid = getenv('TWILIO_ACCOUNT_SID') ?: 'YOUR_ACCOUNT_SID';
        $this->authToken = getenv('TWILIO_AUTH_TOKEN') ?: 'YOUR_AUTH_TOKEN';
        $this->twilioNumber = getenv('TWILIO_PHONE_NUMBER') ?: '+1234567890';
        $this->baseUrl = "https://api.twilio.com/2010-04-01/Accounts/{$this->accountSid}";
    }
    
    /**
     * Generate access token for client
     */
    public function generateAccessToken($identity, $roomName = null) {
        // In a real app, you would use Twilio's PHP SDK
        // For now, we'll return a basic structure
        
        $token = [
            'account_sid' => $this->accountSid,
            'auth_token' => $this->authToken,
            'identity' => $identity,
            'room_name' => $roomName,
            'twilio_number' => $this->twilioNumber
        ];
        
        return $token;
    }
    
    /**
     * Make a voice call
     */
    public function makeCall($toNumber, $fromNumber = null, $twimlUrl = null) {
        $fromNumber = $fromNumber ?: $this->twilioNumber;
        
        // Basic TwiML for voice call
        $twiml = $twimlUrl ?: 'https://your-domain.com/twiml/voice.xml';
        
        $data = [
            'To' => $toNumber,
            'From' => $fromNumber,
            'Url' => $twiml,
            'Method' => 'POST'
        ];
        
        // In a real app, you would use Twilio's PHP SDK
        // For now, we'll simulate the call
        return [
            'success' => true,
            'call_sid' => 'CA' . uniqid(),
            'status' => 'initiated',
            'to' => $toNumber,
            'from' => $fromNumber
        ];
    }
    
    /**
     * Send SMS
     */
    public function sendSMS($toNumber, $message, $fromNumber = null) {
        $fromNumber = $fromNumber ?: $this->twilioNumber;
        
        $data = [
            'To' => $toNumber,
            'From' => $fromNumber,
            'Body' => $message
        ];
        
        // In a real app, you would use Twilio's PHP SDK
        // For now, we'll simulate the SMS
        return [
            'success' => true,
            'message_sid' => 'SM' . uniqid(),
            'status' => 'sent',
            'to' => $toNumber,
            'from' => $fromNumber,
            'body' => $message
        ];
    }
    
    /**
     * Get call logs
     */
    public function getCallLogs($limit = 20) {
        // In a real app, you would fetch from Twilio API
        return [
            'success' => true,
            'calls' => []
        ];
    }
    
    /**
     * Get SMS logs
     */
    public function getSMSLogs($limit = 20) {
        // In a real app, you would fetch from Twilio API
        return [
            'success' => true,
            'messages' => []
        ];
    }
    
    /**
     * Verify phone number
     */
    public function verifyPhoneNumber($phoneNumber) {
        // In a real app, you would use Twilio Verify service
        return [
            'success' => true,
            'verification_sid' => 'VE' . uniqid(),
            'status' => 'pending'
        ];
    }
    
    /**
     * Check verification code
     */
    public function checkVerificationCode($verificationSid, $code) {
        // In a real app, you would verify with Twilio
        return [
            'success' => true,
            'status' => 'approved'
        ];
    }
}

// API endpoints for Twilio integration
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    $action = $input['action'] ?? '';
    
    $twilioService = new TwilioService();
    
    switch ($action) {
        case 'generate_token':
            $identity = $input['identity'] ?? '';
            $roomName = $input['room_name'] ?? null;
            
            if (!$identity) {
                http_response_code(400);
                echo json_encode(['error' => 'Identity is required']);
                exit;
            }
            
            $token = $twilioService->generateAccessToken($identity, $roomName);
            echo json_encode(['success' => true, 'token' => $token]);
            break;
            
        case 'make_call':
            $toNumber = $input['to_number'] ?? '';
            $fromNumber = $input['from_number'] ?? null;
            $twimlUrl = $input['twiml_url'] ?? null;
            
            if (!$toNumber) {
                http_response_code(400);
                echo json_encode(['error' => 'To number is required']);
                exit;
            }
            
            $result = $twilioService->makeCall($toNumber, $fromNumber, $twimlUrl);
            echo json_encode($result);
            break;
            
        case 'send_sms':
            $toNumber = $input['to_number'] ?? '';
            $message = $input['message'] ?? '';
            $fromNumber = $input['from_number'] ?? null;
            
            if (!$toNumber || !$message) {
                http_response_code(400);
                echo json_encode(['error' => 'To number and message are required']);
                exit;
            }
            
            $result = $twilioService->sendSMS($toNumber, $message, $fromNumber);
            echo json_encode($result);
            break;
            
        case 'verify_phone':
            $phoneNumber = $input['phone_number'] ?? '';
            
            if (!$phoneNumber) {
                http_response_code(400);
                echo json_encode(['error' => 'Phone number is required']);
                exit;
            }
            
            $result = $twilioService->verifyPhoneNumber($phoneNumber);
            echo json_encode($result);
            break;
            
        case 'check_verification':
            $verificationSid = $input['verification_sid'] ?? '';
            $code = $input['code'] ?? '';
            
            if (!$verificationSid || !$code) {
                http_response_code(400);
                echo json_encode(['error' => 'Verification SID and code are required']);
                exit;
            }
            
            $result = $twilioService->checkVerificationCode($verificationSid, $code);
            echo json_encode($result);
            break;
            
        default:
            http_response_code(400);
            echo json_encode(['error' => 'Invalid action']);
            break;
    }
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}
?> 