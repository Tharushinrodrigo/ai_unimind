class FinanceBackend {
  // =========================
  // CORE FINANCE DATA
  // =========================
  double salary = 0;
  double budgetTotal = 0;
  double spentTotal = 0;

  double savingsGoal = 0;

  // Expense list (name -> amount)
  Map<String, double> monthlyExpenses = {
    "Food": 0,
    "Transport": 0,
    "Bills": 0,
  };

  // Weekly budget (editable)
  Map<String, double> weeklyBudget = {
    "Week 1": 0,
    "Week 2": 0,
    "Week 3": 0,
    "Week 4": 0,
  };

  // AI suggestion text
  String aiSuggestion = "Keep tracking your expenses consistently.";

  // =========================
  // CALCULATION ENGINE
  // =========================
  void calculateTotals() {
    // 1. Calculate spent total from expenses
    spentTotal = monthlyExpenses.values.fold(0, (a, b) => a + b);

    // 2. Auto budget total from weekly budget
    budgetTotal = weeklyBudget.values.fold(0, (a, b) => a + b);

    // 3. Update AI suggestion
    _generateSuggestion();
  }

  // =========================
  // SIMPLE AI LOGIC
  // =========================
  void _generateSuggestion() {
    double remaining = salary - spentTotal;

    if (salary <= 0) {
      aiSuggestion = "Set your salary to start tracking finances.";
    } else if (spentTotal > salary) {
      aiSuggestion = "⚠ You are overspending! Reduce unnecessary expenses.";
    } else if (remaining < salary * 0.2) {
      aiSuggestion = "Be careful! Low savings this month.";
    } else {
      aiSuggestion = "Good job! You are managing your money well 👍";
    }
  }

  // =========================
  // ADD EXPENSE
  // =========================
  void addExpense(String name, double amount) {
    monthlyExpenses[name] = amount;
    calculateTotals();
  }

  // =========================
  // DELETE EXPENSE
  // =========================
  void deleteExpense(String name) {
    monthlyExpenses.remove(name);
    calculateTotals();
  }

  // =========================
  // UPDATE EXPENSE
  // =========================
  void updateExpense(String name, double amount) {
    if (monthlyExpenses.containsKey(name)) {
      monthlyExpenses[name] = amount;
      calculateTotals();
    }
  }

  // =========================
  // UPDATE SALARY
  // =========================
  void updateSalary(double value) {
    salary = value;
    calculateTotals();
  }

  // =========================
  // UPDATE BUDGET ITEM
  // =========================
  void updateWeeklyBudget(String key, double value) {
    weeklyBudget[key] = value;
    calculateTotals();
  }
}