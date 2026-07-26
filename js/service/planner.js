/**
 * Service Planning - Gestion du calendrier et des statistiques énergétiques
 */
const PlannerService = (function () {
    const DAYS = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    let weeklyMenu = [];

    async function generateWeeklyMenu() {
        // Demande un lot de 7 plats aléatoires à l'API PHP
        const recipes = await ApiService.getRandom(7);
        const cleanRecipes = Array.isArray(recipes) ? recipes : [recipes];

        // Reconstruction totale avec clonage pour forcer le rafraîchissement graphique du DOM
        weeklyMenu = DAYS.map((dayName, index) => {
            const selectedRecipe = cleanRecipes[index % cleanRecipes.length];
            return { 
                dayIndex: index, 
                dayName, 
                recipe: selectedRecipe ? { ...selectedRecipe } : null // Clonage de l'objet
            };
        });
        return weeklyMenu;
    }

        async function swapRecipeForDay(dayIndex) {
        // Sécurité sur l'index du jour
        if (dayIndex < 0 || dayIndex >= weeklyMenu.length) return weeklyMenu;
        
        try {
            // On pioche 5 recettes aléatoires de PostgreSQL pour avoir du choix
            const randomBatch = await ApiService.getRandom(5);
            const cleanBatch = Array.isArray(randomBatch) ? randomBatch : [randomBatch];
            
            // Liste des IDs des plats actuellement affichés pour éviter les doublons
            const currentIds = weeklyMenu.map(item => item.recipe ? item.recipe.id : 0);
            
            // Algorithme : Trouver une recette du lot qui n'est pas déjà dans la semaine
            let newRecipe = cleanBatch.find(r => r && !currentIds.includes(r.id)) || cleanBatch[0];
            
            if (newRecipe) {
                // On remplace STRICTEMENT la recette de ce jour avec un clonage propre
                weeklyMenu[dayIndex].recipe = { ...newRecipe };
            }
        } catch (e) {
            console.error("Erreur lors du swap de recette :", e);
        }
     
        return weeklyMenu;
    }

    function getMenuMetrics() {
        let totalCalories = 0, totalCost = 0;
        weeklyMenu.forEach(item => {
            if (item.recipe) {
                totalCalories += parseInt(item.recipe.calories || 0, 10);
                totalCost += parseFloat(item.recipe.cout_estime || 0);
            }
        });
        return { totalCalories, totalCost: totalCost.toFixed(2) };
    }

    return { 
        generateWeeklyMenu, 
        swapRecipeForDay, 
        getMenuMetrics, 
        getCurrentMenu: () => weeklyMenu, 
        getRecipesOnly: () => weeklyMenu.map(i => i.recipe).filter(Boolean) 
    };
})();
