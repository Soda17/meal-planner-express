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
        if (dayIndex < 0 || dayIndex >= weeklyMenu.length) return;
        
        // Pioche un lot de 5 recettes fraîches au hasard pour le remplacement d'un seul jour
        const randomBatch = await ApiService.getRandom(5);
        const cleanBatch = Array.isArray(randomBatch) ? randomBatch : [randomBatch];
        
        // Liste des IDs déjà affichés dans la semaine pour éviter les doublons directs
        const currentIds = weeklyMenu.map(item => item.recipe ? item.recipe.id : 0);
        
        // Algorithme : Trouver en priorité un plat qui n'est pas encore affiché cette semaine
        let newRecipe = cleanBatch.find(r => r && !currentIds.includes(r.id)) || cleanBatch[0];
        
        if (newRecipe) {
            weeklyMenu[dayIndex].recipe = { ...newRecipe }; // Clonage obligatoire
        }
        return weeklyMenu[dayIndex];
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
