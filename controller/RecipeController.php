<?php
/**
 * Contrôleur des recettes - Meal Planner Express
 */
class RecipeController {
    private PDO $db;

    public function __construct(PDO $db) {
        $this->db = $db;
    }

    public function handleAction(string $action, array $params): void {
        switch ($action) {
            case 'all':
                $this->getAllRecipes(); 
                break;
            case 'random':
                $this->getRandomMenu(); 
                break;
            case 'search':
                $this->searchRecipes($params['q'] ?? '');
                break;
            case 'category':
                $this->getRecipesByCategory($params['cat'] ?? '');
                break;
            case 'country':
                $this->getRecipesByCountry($params['country'] ?? '');
                break;
            case 'quick':
                $this->getQuickRecipes();
                break;
            case 'healthy':
                $this->getHealthyRecipes();
                break;
            case 'recipe':
                $this->getRecipeById((int)($params['id'] ?? 0));
                break;
            default:
                $this->jsonResponse(null, 400, 'Action non reconnue.');
                break;
        }
    }

      private function getAllRecipes(): void {
        $stmt = $this->db->prepare("SELECT * FROM recettes ORDER BY id ASC");
        $stmt->execute();
        $recipes = $stmt->fetchAll();
        $this->jsonResponse($this->formatJsonbColumns($recipes), 200, 'Catalogue complet chargé');
    }

  private function getRandomMenu(): void {
        $this->db->setAttribute(PDO::ATTR_EMULATE_PREPARES, true);
        $stmt = $this->db->prepare("SELECT * FROM recettes ORDER BY RANDOM() LIMIT 7");
        $stmt->execute();
        $recipes = $stmt->fetchAll();
        $this->db->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
        $this->jsonResponse($this->formatJsonbColumns($recipes), 200, 'Menu hebdomadaire généré');
    }

    private function searchRecipes(string $q): void {
        $stmt = $this->db->prepare("SELECT * FROM recettes WHERE nom ILIKE :q OR origine ILIKE :q OR categorie ILIKE :q");
        $stmt->execute([':q' => "%{$q}%"]);
        $recipes = $stmt->fetchAll();
        $this->jsonResponse($this->formatJsonbColumns($recipes), 200, 'Résultats de recherche');
    }

    private function getRecipesByCategory(string $cat): void {
        $stmt = $this->db->prepare("SELECT * FROM recettes WHERE categorie ILIKE :cat");
        $stmt->execute([':cat' => "%{$cat}%"]); // Le % permet de capter la catégorie de façon souple
        $recipes = $stmt->fetchAll();
        $this->jsonResponse($this->formatJsonbColumns($recipes), 200, 'Filtre catégorie');
    }

    private function getRecipesByCountry(string $country): void {
        $stmt = $this->db->prepare("SELECT * FROM recettes WHERE origine ILIKE :country OR nom ILIKE :country");
        $stmt->execute([':country' => "%{$country}%"]); // Le % résout le problème des accents ou déclinaisons
        $recipes = $stmt->fetchAll();
        $this->jsonResponse($this->formatJsonbColumns($recipes), 200, 'Filtre origine');
    }

    private function getQuickRecipes(): void {
        $stmt = $this->db->prepare("SELECT * FROM recettes WHERE temps_preparation <= 35");
        $stmt->execute();
        $recipes = $stmt->fetchAll();
        $this->jsonResponse($this->formatJsonbColumns($recipes), 200, 'Plats express');
    }

    private function getHealthyRecipes(): void {
        $stmt = $this->db->prepare("SELECT * FROM recettes WHERE calories <= 600 AND calories > 0");
        $stmt->execute();
        $recipes = $stmt->fetchAll();
        $this->jsonResponse($this->formatJsonbColumns($recipes), 200, 'Plats légers');
    }

    private function getRecipeById(int $id): void {
        $stmt = $this->db->prepare("SELECT * FROM recettes WHERE id = :id");
        $stmt->execute([':id' => $id]);
        $recipe = $stmt->fetch();
        if ($recipe) {
            $formatted = $this->formatJsonbColumns([$recipe]);
            $this->jsonResponse($formatted, 200, 'Détail de la recette');
        } else {
            $this->jsonResponse(null, 404, 'Recette introuvable');
        }
    }

    private function formatJsonbColumns(array $recipes): array {
        foreach ($recipes as &$recipe) {
            if (isset($recipe['tags']) && is_string($recipe['tags'])) {
                $recipe['tags'] = json_decode($recipe['tags'], true);
            }
            if (isset($recipe['ingredients']) && is_string($recipe['ingredients'])) {
                $recipe['ingredients'] = json_decode($recipe['ingredients'], true);
            }
        }
        return $recipes;
    }

    private function jsonResponse(mixed $data, int $statusCode = 200, string $message = 'Success'): void {
        http_response_code($statusCode);
        header('Content-Type: application/json; charset=utf-8');
        header('Access-Control-Allow-Origin: *');
        echo json_encode([
            'status' => $statusCode >= 200 && $statusCode < 300 ? 'success' : 'error',
            'message' => $message,
            'count' => is_array($data) ? count($data) : 1,
            'data' => $data
        ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
        exit;
    }
}