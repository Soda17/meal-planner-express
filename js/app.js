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
                // 1. On vide visuellement la grille pour montrer le rechargement
                if (plannerGrid) plannerGrid.innerHTML = ''; 
                
                // 2. 🌟 CODE NETTOYÉ : On appelle simplement le service d'origine sans écraser ses fonctions
                const menu = await PlannerService.generateWeeklyMenu();
                
                // 3. Rendu propre à l'écran
                renderPlanner(menu);
                showToast("✨ Nouveau planning de 7 repas généré !");
                
                // 4. Défilement fluide vers la section du calendrier
                if (shouldScroll) {
                    const sec = document.getElementById('planner-section');
                    if (sec) sec.scrollIntoView({ behavior: 'smooth' });
                }
            } catch (e) {
                console.error("Erreur de génération du menu hebdomadaire :", e);
                showToast("⚠️ Échec du rafraîchissement.");
            } finally { 
                showLoader(false); 
            }
        }

       
        function renderPlanner(menu) {
            // SÉCURITÉ : Si la grille n'existe pas dans le HTML, on coupe
            if (!plannerGrid) return;

            // On vide TOUJOURS l'ancien affichage pour forcer le rafraîchissement
            plannerGrid.innerHTML = '';

            if (!menu || menu.length === 0) {
                plannerGrid.innerHTML = `
                    <div class="col-span-full text-center p-8 bg-slate-900/50 rounded-2xl border border-slate-800 text-slate-400">
                        <i class="fa-solid fa-cookie-bite text-3xl text-emerald-500 mb-2"></i>
                        <p class="text-sm">Aucun menu généré. Cliquez sur le bouton pour commencer.</p>
                    </div>
                `;
                return;
            }

            // Boucle de génération des 7 cartes de la semaine
            menu.forEach(item => {
                const recipe = item.recipe;
                if (!recipe) return;

                const card = document.createElement('div');
                card.className = 'group bg-slate-900/60 rounded-2xl border border-slate-800/80 p-4 flex flex-col justify-between hover:border-emerald-500/30 transition-all duration-300 backdrop-blur-sm shadow-xl';

                card.innerHTML = `
                    <div>
                        <div class="flex items-center justify-between mb-3">
                            <span class="px-3 py-1 bg-emerald-500/10 text-emerald-400 font-extrabold text-[10px] rounded-md uppercase tracking-wider">${item.dayName}</span>
                            <button class="swap-day-btn text-[11px] font-semibold text-slate-400 hover:text-emerald-400 flex items-center gap-1 transition-colors" data-day="${item.dayIndex}">
                                <i class="fa-solid fa-rotate"></i> Changer
                            </button>
                        </div>
                        <div class="relative h-32 w-full rounded-xl overflow-hidden mb-3 bg-slate-950">
                            <img src="${recipe.image}" alt="${recipe.nom}" class="w-full h-full object-cover object-center group-hover:scale-105 transition-transform duration-500">
                            <span class="absolute bottom-2 left-2 bg-slate-900/80 text-[10px] px-2 py-0.5 rounded text-white font-medium">
                                <i class="fa-regular fa-clock text-emerald-400"></i> ${recipe.temps_preparation} min
                            </span>
                        </div>
                        <h4 class="font-bold text-white text-sm line-clamp-2 mb-2 cursor-pointer view-recipe-btn hover:text-emerald-400 transition-colors" data-id="${recipe.id}">
                            ${recipe.nom}
                        </h4>
                    </div>
                    <div class="flex items-center justify-between text-[11px] text-slate-400 border-t border-slate-800/60 pt-2.5 mt-2">
                        <span><i class="fa-solid fa-fire text-amber-500"></i> ${recipe.calories} kcal</span>
                        <span class="font-bold text-emerald-400">📊 ${recipe.difficulte}</span>
                    </div>
                `;

                plannerGrid.appendChild(card);
            });

            // 🌟 COMPTAGE DES CALORIES SÉCURISÉ (Remplace updatePlannerMetrics)
            if (typeof PlannerService !== 'undefined' && PlannerService.getMenuMetrics) {
                const metrics = PlannerService.getMenuMetrics();
                const totalCalElem = document.getElementById('menu-total-cal');
                if (totalCalElem) {
                    totalCalElem.textContent = `${metrics.totalCalories} kcal`;
                }
            }
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
                // 1. Récupération des valeurs des éléments HTML
                const querySearch = searchInput ? searchInput.value.trim() : '';
                const queryCategory = categoryFilter ? categoryFilter.value : '';
                const queryCountry = countryFilter ? countryFilter.value : '';

                // 2. Logique séquentielle des filtres
                if (isQuickActive) {
                    recipes = await ApiService.getQuick();
                } else if (isHealthyActive) {
                    recipes = await ApiService.getHealthy();
                } else if (querySearch !== '') {
                    recipes = await ApiService.search(querySearch);
                } else if (queryCategory !== '') {
                    recipes = await ApiService.getByCategory(queryCategory);
                } else if (queryCountry !== '') {
                    // ⚡ On s'assure d'appeler correctement le service pays
                    recipes = await ApiService.getByCountry(queryCountry);
                } else {
                    // Si aucun filtre n'est coché, on affiche l'INTEGRALITÉ du catalogue
                    recipes = await ApiService.getAll();
                }
                
                // 3. Envoi à la grille pour affichage
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
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(loadRecipesCatalog, 300);
        });
    }

    // 2. Filtre par Catégorie
    const targetCategoryFilter = document.getElementById('category-filter');
    if (targetCategoryFilter) {
        targetCategoryFilter.addEventListener('change', async () => {
            console.log("📂 Action : Changement de catégorie détecté ->", targetCategoryFilter.value);
            await loadRecipesCatalog();
        });
    }

    // 3. Filtre par Pays / Origine
  const targetCountryFilter = document.getElementById('country-filter');
    if (targetCountryFilter) {
        
        targetCountryFilter.removeAttribute('onchange'); 
        
        targetCountryFilter.addEventListener('change', async () => {
            console.log("📍 Action : Changement de pays détecté ->", targetCountryFilter.value);
            
            // On force le déclenchement immédiat du chargement PostgreSQL
            await loadRecipesCatalog(); 
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
        // ==========================================================================
    // ⚡ GESTION CENTRALISÉE DES CLICS SUR LE PLANNING DU HAUT (js/app.js)
    // ==========================================================================
    if (plannerGrid) {
        plannerGrid.addEventListener('click', async (e) => {
            
            // 🔍 CAS A : L'utilisateur a cliqué sur le bouton "Changer"
            const swapBtn = e.target.closest('.swap-day-btn');
            if (swapBtn) {
                e.preventDefault();
                const dayIndex = parseInt(swapBtn.getAttribute('data-day'), 10);
                
                showLoader(true);
                try {
                    await PlannerService.swapRecipeForDay(dayIndex);
                    const fullMenu = PlannerService.getCurrentMenu();
                    renderPlanner(fullMenu);
                    showToast("🔄 Plat du jour mis à jour !");
                } catch (err) {
                    console.error("Erreur lors du changement de plat :", err);
                } finally {
                    showLoader(false);
                }
                return; // On arrête l'exécution ici si c'était un bouton changer
            }

            // 🔍 CAS B : L'utilisateur a cliqué sur le TITRE du plat pour voir la recette
            const recipeBtn = e.target.closest('.view-recipe-btn');
            if (recipeBtn) {
                e.preventDefault();
                const recipeId = recipeBtn.getAttribute('data-id');
                console.log("🔍 Ouverture de la modale depuis le planning pour l'ID :", recipeId);
                
                // Appel de votre fonction existante qui ouvre et remplit la modale
                await openRecipeDetailModal(recipeId);
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
