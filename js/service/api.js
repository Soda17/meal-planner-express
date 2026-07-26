/**
 * Client API REST & Module Fallback Standalone
 * Meal Planner Express - JavaScript ES6+
 */

const ApiService = (function () {
    const API_BASE_URL = 'api.php';

    /**
     * Fallback de sécurité - Unifié pour éviter les crashs et les écrans figés
     */
    function handleFallback(action, params) {
        console.warn(`[ApiService] Latence réseau ou PostgreSQL indisponible pour l'action : ${action}`);
        
        // Objet de secours pour que l'interface reste toujours active et fluide
        const mockRecipe = {
            id: 1,
            nom: "Chargement dynamique en cours...",
            categorie: "Sélection",
            origine: "Meal Planner",
            temps_preparation: 30,
            calories: 600,
            portions: 4,
            cout_estime: 12.50,
            image: "images/yassa.jpg", 
            ingredients: [{ nom: "Vérifiez vos insertions dans pgAdmin", quantite: 1, unite: "pièce" }],
            instructions: "Si ce message persiste, assurez-vous que PostgreSQL est bien démarré."
        };

        if (action === 'recipe') return mockRecipe;
        return Array(7).fill(null).map((_, i) => ({ ...mockRecipe, id: i + 1 }));
    }

    /**
     * Méthode générique de requête vers l'API PHP avec système anti-cache
     */
    async function fetchApi(action, params = {}) {
        if (window.location.protocol === 'file:') return handleFallback(action, params);
        const queryParams = new URLSearchParams({ 
            action, 
            ...params, 
            _t: Date.now() 
        });
        
        try {
            const response = await fetch(`${API_BASE_URL}?${queryParams.toString()}`);
            if (!response.ok) throw new Error(`HTTP Error: ${response.status}`);
            
            const json = await response.json();
            if (json.status === 'success' && json.data) {
                return json.data;
            }
            return handleFallback(action, params);
        } catch (e) {
            console.error("[ApiService] Erreur réseau ou latence base de données :", e);
            return handleFallback(action, params);
        }
    }

    return {
        getRandom: (limit = 7) => fetchApi('random', { limit }),
        search: (q) => fetchApi('search', { q }),
        getByCategory: (cat) => fetchApi('category', { cat }),
        getByCountry: (country) => fetchApi('country', { country }),
        getQuick: () => fetchApi('quick'),
        getHealthy: () => fetchApi('healthy'),
        getById: (id) => fetchApi('recipe', { id: id }), 
        getAll: () => fetchApi('all')
    };
})();
