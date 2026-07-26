<?php
/**
 * Configuration de la connexion à la Base de Données PostgreSQL avec PDO
 * Meal Planner Express - Architecture Produit Portfolio
 */

class Database {
    private string $host;
    private string $port;
    private string $db_name;
    private string $username;
    private string $password;
    private ?PDO $conn = null;

    public function __construct() {
        // Chargement des paramètres depuis l'environnement ou valeurs par défaut
        $this->host = getenv('DB_HOST') ?: 'localhost';
        $this->port = getenv('DB_PORT') ?: '5432';
        $this->db_name = getenv('DB_NAME') ?: 'meal_planner';
        $this->username = getenv('DB_USER') ?: 'postgres';
        $this->password = getenv('DB_PASSWORD') ?: '3226';
    }

    /**
     * Obtenir l'instance unique de connexion PDO PostgreSQL
     * @return PDO
     * @throws Exception
     */
    public function getConnection(): PDO {
        if ($this->conn === null) {
            try {
                $dsn = "pgsql:host={$this->host};port={$this->port};dbname={$this->db_name};";
                
                $options = [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ];

                $this->conn = new PDO($dsn, $this->username, $this->password, $options);
            } catch (PDOException $e) {
                // Journalisation de l'erreur réseau / base de données
                error_log("Erreur de connexion PostgreSQL: " . $e->getMessage());
                throw new Exception("Impossible de se connecter à la base de données PostgreSQL: " . $e->getMessage());
            }
        }

        return $this->conn;
    }
}
