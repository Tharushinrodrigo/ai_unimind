
class FinanceBackend {
  // මූලික දත්ත
  double salary = 85000.0;
  double savingsGoal = 20000.0;
  
  // වියදම් ලැයිස්තුව (Monthly Expenses)
  Map<String, double> monthlyExpenses = {
    "Boarding Fees": 15000.0,
    "Food & Drinks": 12000.0,
    "Transport": 5000.0,
    "Internet & Mobile": 2500.0,
  };

  // සතිපතා බජට් එක (Weekly Budget)
  Map<String, double> weeklyBudget = {
    "Week 01": 5000.0,
    "Week 02": 5000.0,
    "Week 03": 5000.0,
    "Week 04": 5000.0,
  };

  double spentTotal = 0;
  double budgetTotal = 0;
  String aiSuggestion = "You've saved 15% more than last month. Keep it up!";

  // සියලුම එකතුවන් ගණනය කිරීම
  void calculateTotals() {
    // වියදම් එකතුව
    spentTotal = monthlyExpenses.values.fold(0, (sum, item) => sum + item);
    
    // බජට් එකතුව
    budgetTotal = weeklyBudget.values.fold(0, (sum, item) => sum + item);
    
    // AI උපදෙස් යාවත්කාලීන කිරීම (සරලව)
    if (spentTotal > salary) {
      aiSuggestion = "Warning: Your expenses exceed your salary! Try to cut down.";
    } else if (spentTotal > (salary * 0.8)) {
      aiSuggestion = "You are close to your limit. Watch your 'Food & Drinks' expenses.";
    } else {
      aiSuggestion = "Great job! You are managing your finances well this month.";
    }
  }
}