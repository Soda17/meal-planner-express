<?php
/**
 * Routeur API Centralisé - Meal Planner Express
 */

header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Cache-Control: post-check=0, pre-check=0', false);
header('Pragma: no-cache');

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/controller/RecipeController.php';



try {
    $database = new Database();
    $db = $database->getConnection();

    $action = $_GET['action'] ?? 'random';
    
    $controller = new RecipeController($db);
    $controller->handleAction($action, $_GET);

} catch (Exception $e) {
    // Si la base de données PostgreSQL est éteinte ou mal configurée,
    // on renvoie un statut "fallback" pour que le JavaScript prenne le relais proprement
    http_response_code(200); 
    echo json_encode([
        'status' => 'fallback',
        'message' => 'Connexion PostgreSQL indisponible, bascule sur les données locales.',
        'error_debug' => $e->getMessage(),
        'data' => []
    ]);
    exit;
}