document.addEventListener('DOMContentLoaded', async () => {
    
    // 1. Captures des éléments DOM
    const generateMenuBtn = document.getElementById('generate-menu-btn');
    const newMenuBtn = document.getElementById('new-menu-btn');
    const openShoppingBtn = document.getElementById('open-shopping-btn');
    
    // Sécurité pour la modale shopping retirée du HTML
    const shoppingModal = null; 
    
    const shoppingProgressBar = document.getElementById('shopping-progress-bar');
    const shoppingProgressText = document.getElementById('shopping-progress-text');
    const printShoppingBtn = document.getElementById('print-shopping-btn');
    const copyShoppingBtn = document.getElementById('copy-shopping-btn');
    const resetShoppingBtn = document.getElementById('reset-shopping-btn');
    const recipeModal = document.getElementById('recipe-modal');
    const closeRecipeBtn = document.getElementById('close-recipe-btn');
    const recipeModalContent = document.getElementById('recipe-modal-content');
    const searchInput = document.getElementById('search-input');
    const categoryFilter = document.getElementById('category-filter');
    const countryFilter = document.getElementById('country-filter');
    const quickFilterBtn = document.getElementById('quick-filter-btn');
    const healthyFilterBtn = document.getElementById('healthy-filter-btn');
    const resetFiltersBtn = document.getElementById('reset-filters-btn');
    const plannerGrid = document.getElementById('planner-grid');
    const recipesGrid = document.getElementById('recipes-grid');
    const noResultsMsg = document.getElementById('no-results');
    const recipesLoading = document.getElementById('recipes-loading');

    // 2. Déclaration unique des variables d'état locales
    let isQuickActive = false, isHealthyActive = false, searchTimeout = null;

    // 3. Fonctions utilitaires globales du contrôleur
    function showLoader(s) { 
        const loadingElem = document.getElementById('recipes-loading');
        if (loadingElem) loadingElem.classList.toggle('hidden', !s); 
    }
    
    function showToast(m) { 
        const t = document.createElement('div'); 
        t.className = 'fixed bottom-6 right-6 z-50 px-5 py-3 rounded-xl font-semibold text-sm text-white bg-emerald-600 shadow-2xl animate-fade-in'; 
        t.textContent = m; 
        document.body.appendChild(t); 
        setTimeout(() => t.remove(), 3000); 
    }

    // 4. Lancement asynchrone sécurisé du cycle de vie de l'application
    await initApp();

    async function initApp() {
        showLoader(true);
        try {
            await handleGenerateMenu(false);
            await loadRecipesCatalog();
        } catch (e) {
            console.error("Erreur lors de l'initialisation de l'application :", e);
        } finally { 
            showLoader(false); 
        }
    }

    async function handleGenerateMenu(shouldScroll = true) {
            showLoader(true);
            try {
                if (plannerGrid) plannerGrid.innerHTML = ''; 
            
                if (typeof PlannerService !== 'undefined') {
                    PlannerService.generateWeeklyMenu = async function() {
                        const recipes = await ApiService.getRandom(7);
                        this.weeklyMenu = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'].map((dayName, index) => ({ 
                            dayIndex: index, 
                            dayName, 
                            recipe: recipes[index] || recipes[0] 
                        }));
                        return this.weeklyMenu;
                    };
                }

                const menu = await PlannerService.generateWeeklyMenu();
                
                // 4. RENDU À L'ÉCRAN
                renderPlanner(menu);
                showToast("✨ Nouveau planning de 7 repas généré !");
                
                if (shouldScroll) {
                    const sec = document.getElementById('planner-section');
                    if (sec) sec.scrollIntoView({ behavior: 'smooth' });
                }
            } catch (e) {
                console.error("Erreur de génération :", e);
                showToast("⚠️ Échec du rafraîchissement.");
            } finally { 
                showLoader(false); 
            }
        }

    function renderPlanner(menu) {
        if (!plannerGrid) return;
        plannerGrid.innerHTML = '';
        menu.forEach(item => {
            const recipe = item.recipe;
            if (!recipe) return;
            const card = document.createElement('div');
            card.className = 'glass-card rounded-2xl overflow-hidden p-4 flex flex-col justify-between border border-slate-700/50 hover:border-emerald-500/40 transition-all';
            card.innerHTML = `
                <div>
                    <div class="flex items-center justify-between mb-3">
                        <span class="px-3 py-1 bg-emerald-500/20 text-emerald-300 font-bold text-xs rounded-full uppercase tracking-wider">${item.dayName}</span>
                        <button class="swap-day-btn text-xs text-slate-400 hover:text-emerald-400 flex items-center gap-1 transition-colors" data-day="${item.dayIndex}"><i class="fa-solid fa-rotate"></i> Changer</button>
                    </div>
                    <div class="relative h-44 w-full overflow-hidden rounded-xl mb-3 bg-slate-900">
                        <img src="${recipe.image}" alt="${recipe.nom}" class="w-full h-full object-cover object-center group-hover:scale-105 transition-transform duration-500">
                        <span class="absolute bottom-2 left-2 bg-slate-900/80 text-xs px-2 py-1 rounded text-white font-medium">
                            <i class="fa-regular fa-clock text-emerald-400"></i> ${recipe.temps_preparation} min
                        </span>
                    </div>
                    <h4 class="font-bold text-white text-sm line-clamp-2 mb-2 cursor-pointer view-recipe-btn" data-id="${recipe.id}">${recipe.nom}</h4>
                </div>
                <div class="flex items-center justify-between text-xs text-slate-400 border-t border-slate-700/50 pt-2 mt-2">
                    <span><i class="fa-solid fa-fire text-amber-400"></i> ${recipe.calories} kcal</span>
                            <span class="font-semibold text-emerald-400">📊 ${recipe.difficulte}</span>

                </div>
            `;
            plannerGrid.appendChild(card);
        });

        const metrics = PlannerService.getMenuMetrics();
        if (document.getElementById('menu-total-cal')) document.getElementById('menu-total-cal').textContent = `${metrics.totalCalories} kcal`;

        addPlannerListeners();
    }

    function addPlannerListeners() {
        document.querySelectorAll('.swap-day-btn').forEach(btn => {
            btn.addEventListener('click', async (e) => {
                const dayIndex = parseInt(e.currentTarget.getAttribute('data-day'), 10);
                await PlannerService.swapRecipeForDay(dayIndex);
                renderPlanner(PlannerService.getCurrentMenu());
                showToast("✨ Repas remplacé !");
            });
        });
        document.querySelectorAll('.view-recipe-btn').forEach(btn => {
            btn.addEventListener('click', (e) => openRecipeDetailModal(parseInt(e.currentTarget.getAttribute('data-id'), 10)));
        });
    }

    async function loadRecipesCatalog() {
        showLoader(true);
        let recipes = [];
        try {
            // 1. Récupération des valeurs des filtres
            const querySearch = searchInput ? searchInput.value.trim() : '';
            const queryCategory = categoryFilter ? categoryFilter.value : '';
            const queryCountry = countryFilter ? countryFilter.value : '';

            // 2. Logique algorithmique des filtres croisés
            if (isQuickActive) {
                recipes = await ApiService.getQuick();
            } else if (isHealthyActive) {
                recipes = await ApiService.getHealthy();
            } else if (querySearch !== '') {
                recipes = await ApiService.search(querySearch);
            } else if (queryCategory !== '') {
                recipes = await ApiService.getByCategory(queryCategory);
            } else if (queryCountry !== '') {
                recipes = await ApiService.getByCountry(queryCountry);
            } else {
                // 🌟 Si TOUS les filtres sont vides ou réinitialisés, on charge TOUT le catalogue PostgreSQL
                recipes = await ApiService.getAll();
            }

            renderRecipesGrid(recipes);
        } catch (e) {
            console.error("Erreur lors du filtrage du catalogue :", e);
        } finally {
            showLoader(false);
        }
    }


    function renderRecipesGrid(recipes) {
        if (!recipesGrid) return;
        recipesGrid.innerHTML = '';
        if (!recipes || recipes.length === 0) {
            noResultsMsg?.classList.remove('hidden');
            return;
        }
        noResultsMsg?.classList.add('hidden');

        recipes.forEach(recipe => {
            const card = document.createElement('div');
            card.className = 'glass-card rounded-2xl overflow-hidden flex flex-col justify-between border border-slate-700/60 hover:border-emerald-500/50 transition-all group';
            card.innerHTML = `
                <div>
                   <div class="relative h-56 w-full overflow-hidden bg-slate-950">
                        <img src="${recipe.image}" alt="${recipe.nom}" class="w-full h-full object-cover object-center group-hover:scale-105 transition-transform duration-500 opacity-90 group-hover:opacity-100">
                        <span class="absolute top-3 right-3 bg-emerald-600/90 text-white text-[10px] font-extrabold uppercase tracking-wider px-2.5 py-1 rounded-full">${recipe.categorie}</span>
                        <span class="absolute bottom-3 left-3 bg-slate-900/80 text-slate-200 text-[11px] px-2.5 py-1 rounded-md font-medium">📍 ${recipe.origine}</span>
                    </div>
                                        <div class="p-5">
                        <h3 class="text-lg font-bold text-white mb-3 line-clamp-1">${recipe.nom}</h3>
                        <div class="grid grid-cols-3 gap-2 text-xs text-slate-300 bg-slate-800/40 p-2.5 rounded-xl border border-slate-700/50 mb-4">
                            <div class="text-center"><span class="block text-slate-400">Durée</span><span class="font-semibold text-white">${recipe.temps_preparation} min</span></div>
                            <div class="text-center border-x border-slate-700/50"><span class="block text-slate-400">Calories</span><span class="font-semibold text-white">${recipe.calories}</span></div>
                           <div class="text-center"><span class="block text-slate-400">Difficulté</span><span class="font-semibold text-emerald-400">${recipe.difficulte}</span></div>
                        </div>
                    </div>
                </div>
                <div class="px-5 pb-5">
                    <button class="w-full py-2.5 px-4 bg-slate-800 hover:bg-emerald-600 text-slate-200 hover:text-white rounded-xl font-semibold text-sm view-recipe-btn" data-id="${recipe.id}">
                        <i class="fa-regular fa-eye"></i> Voir la recette
                    </button>
                </div>
            `;
            recipesGrid.appendChild(card);
        });

        document.querySelectorAll('#recipes-grid .view-recipe-btn').forEach(btn => {
            btn.addEventListener('click', (e) => openRecipeDetailModal(parseInt(e.currentTarget.getAttribute('data-id'), 10)));
        });
    }

    // ===============================
    // MODAL DETAIL RECETTE
    // ===============================

   async function openRecipeDetailModal(id) {
            showLoader(true);
            try {
                // 1. Récupération de la réponse brute de l'API
                let recipe = await ApiService.getById(id);
                if (!recipe) return;

                // 🌟 SÉCURITÉ ALGORITHMIQUE : Si PHP renvoie un tableau contenant l'objet (ex: [$recipe])
                // On extrait proprement le premier élément de l'index 0
                if (Array.isArray(recipe)) {
                    recipe = recipe[0];
                }

                // Si malgré cela l'objet est corrompu, on coupe proprement l'exécution
                if (!recipe || !recipe.nom) {
                    console.error("Structure de recette invalide reçue de l'API :", recipe);
                    return;
                }

                // 2. Génération du HTML sécurisé pour les ingrédients
                const ingHtml = (recipe.ingredients || []).map(i => `
                    <li class="flex items-center justify-between p-2 bg-slate-800/40 rounded-xl text-sm">
                        <span class="text-slate-200">${i.nom}</span>
                        <span class="text-emerald-400 font-semibold">${i.quantite} ${i.unite}</span>
                    </li>
                `).join('');

                // 3. Injection dynamique dans la fenêtre modale HTML
                recipeModalContent.innerHTML = `
                    <div class="relative h-64 w-full overflow-hidden rounded-2xl border border-slate-800 bg-slate-950">
                        <img src="${recipe.image}" class="w-full h-full object-cover object-center" alt="${recipe.nom}">
                        <div class="absolute bottom-4 left-4 bg-slate-900/90 p-3 rounded-xl backdrop-blur-sm">
                            <h2 class="text-xl font-extrabold text-white">${recipe.nom}</h2>
                            <span class="text-xs text-emerald-400">${recipe.categorie} • ${recipe.origine}</span>
                        </div>
                    </div>
                    </div>
                    <div class="grid grid-cols-4 gap-2 text-center text-xs mb-4">
                        <div class="p-3 bg-slate-800 rounded-xl"><span class="text-slate-400 block">Temps</span><strong>${recipe.temps_preparation} min</strong></div>
                        <div class="p-3 bg-slate-800 rounded-xl"><span class="text-slate-400 block">Calories</span><strong>${recipe.calories} kcal</strong></div>
                        <div class="p-3 bg-slate-800 rounded-xl"><span class="text-slate-400 block">Portions</span><strong>${recipe.portions} pers.</strong></div>
                        <div class="p-3 bg-slate-800 rounded-xl"><span class="text-slate-400 block">Coût</span><strong class="text-emerald-400">${recipe.cout_estime} €</strong></div>
                    </div>
                    <div class="grid md:grid-cols-2 gap-4">
                        <div><h3 class="font-bold text-white mb-2 uppercase text-xs tracking-wider text-emerald-400">Ingrédients</h3><ul class="space-y-1.5">${ingHtml}</ul></div>
                        <div><h3 class="font-bold text-white mb-2 uppercase text-xs tracking-wider text-emerald-400">Instructions</h3><p class="text-xs text-slate-300 bg-slate-800/40 p-3 rounded-xl leading-relaxed whitespace-pre-line">${recipe.instructions}</p></div>
                    </div>
                `;
                
                recipeModal.classList.remove('hidden');
            } catch (error) {
                console.error("Erreur lors de l'ouverture de la modale recette :", error);
            } finally {
                showLoader(false);
            }
        }



    // 1. Recherche textuelle (se déclenche 300ms après la fin de la frappe)
    if (searchInput) {
        searchInput.addEventListener('input', () => {
            if (!checkFilterPermission()) return; 
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(loadRecipesCatalog, 300);
        });
    }

    // 2. Filtre par Catégorie
    if (categoryFilter) {
        categoryFilter.addEventListener('change', () => {
            if (!checkFilterPermission()) return; 
            console.log("Filtre catégorie activé :", categoryFilter.value);
            loadRecipesCatalog();
        });
    }

    // 3. Filtre par Pays / Origine
    if (countryFilter) {
        countryFilter.addEventListener('change', () => {
            if (!checkFilterPermission()) return; 
            console.log("Filtre pays activé :", countryFilter.value);
            loadRecipesCatalog();
        });
    }

    // 4. Fermeture de la modale détail via le bouton "Croix"
    if (closeRecipeBtn) {
        closeRecipeBtn.addEventListener('click', (e) => {
            e.preventDefault();
            recipeModal.classList.add('hidden');
        });
    }

    // 5. BOUTON CHANGER (Nouveau) : Modifie un seul jour sans faire disparaître la grille
    if (plannerGrid) {
        plannerGrid.addEventListener('click', async (e) => {
            // Détecte si le clic s'est fait sur le bouton "Changer" ou son icône
            const swapBtn = e.target.closest('.swap-day-btn');
            if (swapBtn) {
                e.preventDefault();
                const dayIndex = parseInt(swapBtn.getAttribute('data-day'), 10);
                
                showLoader(true);
                try {
                    // Appelle le service pour modifier la recette de ce jour spécifique
                    await PlannerService.swapRecipeForDay(dayIndex);
                    
                    // Récupère l'état complet du menu mis à jour
                    const fullMenu = PlannerService.getCurrentMenu();
                    
                    // Redessine instantanément la grille du planning à l'écran
                    renderPlanner(fullMenu);
                    showToast("🔄 Plat du jour mis à jour !");
                } catch (err) {
                    console.error("Erreur lors du changement de plat :", err);
                } finally {
                    showLoader(false);
                }
            }
        });
    }

    // 6. Gestion du clic sur le bouton principal "Générer mon menu"
    if (generateMenuBtn) {
        generateMenuBtn.addEventListener('click', async (e) => {
            e.preventDefault();
            await handleGenerateMenu(true);
        });
    }

    // 7. Gestion du bouton "Nouveau menu" (Rafraîchissement global)
    if (newMenuBtn) {
        newMenuBtn.addEventListener('click', async (e) => {
            e.preventDefault();
            console.log("🔄 Demande d'un nouveau menu hebdomadaire...");
            if (plannerGrid) plannerGrid.innerHTML = ''; 
            await handleGenerateMenu(true);
        });
    }

    // 8. Gestion de la fermeture des modales au clic sur le fond sombre (Unifié)
    window.addEventListener('click', (e) => {
        if (recipeModal && e.target === recipeModal) {
            recipeModal.classList.add('hidden');
        }
        if (typeof shoppingModal !== 'undefined' && shoppingModal && e.target === shoppingModal) {
            shoppingModal.classList.add('hidden');
        }
    });

});
