<?php
/**
 * Modèle Métier - Recette
 * Gestion des requêtes PostgreSQL avec requêtes préparées sécurisées (PDO)
 */

class Recipe {
    private PDO $db;
    private string $table = 'recettes';

    public function __construct(PDO $db) {
        $this->db = $db;
    }

    /**
     * Formater les champs JSONB pour le retour API
     */
    private function formatRecipe(array $row): array {
        if (isset($row['tags']) && is_string($row['tags'])) {
            $row['tags'] = json_decode($row['tags'], true) ?? [];
        }
        if (isset($row['ingredients']) && is_string($row['ingredients'])) {
            $row['ingredients'] = json_decode($row['ingredients'], true) ?? [];
        }
        $row['temps_preparation'] = (int) $row['temps_preparation'];
        $row['calories'] = (int) $row['calories'];
        $row['portions'] = (int) $row['portions'];
        $row['cout_estime'] = (float) $row['cout_estime'];
        return $row;
    }

    /**
     * Génère un menu de N repas aléatoires (par défaut 7)
     */
    public function getRandom(int $limit = 7): array {
        $query = "SELECT * FROM {$this->table} ORDER BY RANDOM() LIMIT :limit";
        $stmt = $this->db->prepare($query);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        
        $recipes = $stmt->fetchAll();
        return array_map([$this, 'formatRecipe'], $recipes);
    }

    /**
     * Recherche par nom de recette ou mots-clés
     */
    public function search(string $searchTerm): array {
        $query = "SELECT * FROM {$this->table} WHERE LOWER(nom) LIKE LOWER(:term) OR LOWER(categorie) LIKE LOWER(:term) ORDER BY nom ASC";
        $stmt = $this->db->prepare($query);
        $stmt->bindValue(':term', '%' . trim($searchTerm) . '%', PDO::PARAM_STR);
        $stmt->execute();

        $recipes = $stmt->fetchAll();
        return array_map([$this, 'formatRecipe'], $recipes);
    }

    /**
     * Filtrer par catégorie
     */
    public function getByCategory(string $category): array {
        $query = "SELECT * FROM {$this->table} WHERE LOWER(categorie) = LOWER(:cat) ORDER BY nom ASC";
        $stmt = $this->db->prepare($query);
        $stmt->bindValue(':cat', trim($category), PDO::PARAM_STR);
        $stmt->execute();

        $recipes = $stmt->fetchAll();
        return array_map([$this, 'formatRecipe'], $recipes);
    }

    /**
     * Filtrer par pays d'origine
     */
    public function getByCountry(string $country): array {
        $query = "SELECT * FROM {$this->table} WHERE LOWER(origine) = LOWER(:country) ORDER BY nom ASC";
        $stmt = $this->db->prepare($query);
        $stmt->bindValue(':country', trim($country), PDO::PARAM_STR);
        $stmt->execute();

        $recipes = $stmt->fetchAll();
        return array_map([$this, 'formatRecipe'], $recipes);
    }

    /**
     * Obtenir les recettes express (<= 20 minutes)
     */
    public function getQuick(int $maxMinutes = 20): array {
        $query = "SELECT * FROM {$this->table} WHERE temps_preparation <= :maxTime ORDER BY temps_preparation ASC";
        $stmt = $this->db->prepare($query);
        $stmt->bindValue(':maxTime', $maxMinutes, PDO::PARAM_INT);
        $stmt->execute();

        $recipes = $stmt->fetchAll();
        return array_map([$this, 'formatRecipe'], $recipes);
    }

    /**
     * Obtenir les recettes saines (<= 500 kcal)
     */
    public function getHealthy(int $maxCalories = 500): array {
        $query = "SELECT * FROM {$this->table} WHERE calories <= :maxCal ORDER BY calories ASC";
        $stmt = $this->db->prepare($query);
        $stmt->bindValue(':maxCal', $maxCalories, PDO::PARAM_INT);
        $stmt->execute();

        $recipes = $stmt->fetchAll();
        return array_map([$this, 'formatRecipe'], $recipes);
    }

    /**
     * Obtenir une recette par son ID
     */
    public function getById(int $id): ?array {
        $query = "SELECT * FROM {$this->table} WHERE id = :id LIMIT 1";
        $stmt = $this->db->prepare($query);
        $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        $recipe = $stmt->fetch();
        return $recipe ? $this->formatRecipe($recipe) : null;
    }

    /**
     * Obtenir toutes les recettes
     */
    public function getAll(): array {
        $query = "SELECT * FROM {$this->table} ORDER BY created_at DESC";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        $recipes = $stmt->fetchAll();
        return array_map([$this, 'formatRecipe'], $recipes);
    }

    /**
     * Obtenir la liste distincte des catégories disponibles
     */
    public function getCategories(): array {
        $query = "SELECT DISTINCT categorie FROM {$this->table} ORDER BY categorie ASC";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        return array_column($stmt->fetchAll(), 'categorie');
    }

    /**
     * Obtenir la liste distincte des pays d'origine
     */
    public function getCountries(): array {
        $query = "SELECT DISTINCT origine FROM {$this->table} ORDER BY origine ASC";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        return array_column($stmt->fetchAll(), 'origine');
    }
}
