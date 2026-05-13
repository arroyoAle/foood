# Foood Project Roadmap & TODO

## MVP

### 1. Home Screen & Dashboard
- [x] Replace default counter app with a functional dashboard.
- [ ] Add "Next Meal" widget.
- [x] Add "Quick Access" to active shopping lists.
- [x] Add "Recent Recipes" section.

### 2. Meal Planning
- [ ] Implement `MealPlan` and `MealPlanEntry` database tables.
- [ ] Create `MealPlanRepository` and Riverpod notifiers.
- [ ] Develop `WeekPage` for weekly meal scheduling.
- [ ] Support scaling recipe portions in meal plan entries.

### 3. Shopping List Enhancements
- [x] Add search functionality
- [ ] Add filter functionality
- [x] Allow collapsing of categories
- [ ] Support adding images to items for more clarity
- [x] Add drag and drop support to re-order items

### 4. Recipe Management
- [x] Save name changes
- [ ] Support editing ingredients and instructions
- [ ] Support adding images to recipes.
- [ ] Implement recipe tags (Vegetarian, Quick, Dinner, etc.).
- [ ] Add search and filter functionality to `AllRecipesPage`.

### 5. Pantry Management
- [ ] Update `PantryItems` schema (expiry date, location, last updated).
- [ ] Create Pantry Management screen (list view, add/edit items).

### 6. Spin Wheel
- [ ] Create spin wheel page and add what should I eat today feature

---
## Future Enhancements

### 1. Shopping List
- [ ] Implement auto-generation logic: Aggregate ingredients from Meal Plan - Deduct Pantry = Shopping List.
- [ ] Create custom categories

### 2. Recipe Management
- [ ] Add Recipe Scraping from URLs (Parse ingredients and steps).
- [ ] Share and receive recipes

### 3. Pantry Management
- [ ] Implement low-stock alerts.


---

## Technical & Infrastructure

### 1. Data & Persistence
- [ ] Refine `Items` table to handle unit normalisation (e.g., g vs kg, ml vs l).
- [ ] Implement database migrations for new schema changes.
- [ ] Add unit tests for Repositories and DAOs.

### 2. UI/UX
- [ ] Implement Light/Dark mode support.
- [ ] Add animations for list transitions and navigation.

---

## Completed Tasks
- [x] Initial project setup (Flutter, Riverpod, Drift).
- [x] Basic Recipe and Shopping List CRUD structure.
- [x] Basic drawer navigation.

### Shopping Lists
- [x] Create shopping lists
- [x] Support manual entry of items in shopping lists.
- [x] Category-based sorting in shopping lists (Produce, Meat, Dairy, etc.).

### Recipes
- [x] Create recipes
- [x] Add ingredients
- [x] Add instructions
