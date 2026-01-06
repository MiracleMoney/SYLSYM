import 'package:flutter/material.dart';

// 지출 카테고리
class ExpenseCategory {
  // 고정비 카테고리
  static const fixedExpenses = 'FixedExpenses';
  static const fixedExpensesSubcategories = {
    'CarInsurance': 'Car Insurance',
    'CarLoan': 'Car Loan',
    'HealthInsurance': 'Health Insurance',
    'ManagementFee': 'Management Fee',
    'MobileBill': 'Mobile Bill',
    'RentLease': 'Rent/Lease',
    'Transportation': 'Transportation',
    'Utilities': 'Utilities',
    'CreditLoan': 'Credit Loan',
    'JeonseLoan': 'Jeonse Loan',
    'Mortgage': 'Mortgage',
    'Other': 'Other',
  };

  // 생활비 카테고리
  static const livingExpenses = 'LivingExpenses';
  static const livingExpensesSubcategories = {
    'Alcohol': 'Alcohol',
    'Cigarettes': 'Cigarettes',
    'Clothes': 'Clothes',
    'DailyGoods': 'Daily Goods',
    'Delivery': 'Delivery',
    'Drinks': 'Drinks',
    'EatingOut': 'Eating Out',
    'Gathering': 'Gathering',
    'Groceries': 'Groceries',
    'Shoes': 'Shoes',
  };

  // 투자 카테고리
  static const investmentExpenses = 'InvestmentExpenses';
  static const investmentExpensesSubcategories = {
    'PensionSaving': 'Pension Saving',
    'IRP': 'IRP',
    'ExtraInvestmentIRP': 'Extra Investment IRP',
    'ExtraInvestmentExchange': 'Extra Investment Exchange',
    'ExtraInvestmentGeneral': 'Extra Investment General',
    'ExtraInvestmentPension': 'Extra Investment Pension',
  };

  // 저축 카테고리
  static const savingExpenses = 'SavingExpenses';
  static const savingExpensesSubcategories = {
    'EmergencyFund': 'Emergency Fund',
    'ShortTermGoal': 'Short-term Goal',
    'ExtraSavingHouseFund': 'Extra Saving House Fund',
    'ExtraSavingHousingSub': 'Extra Saving Housing Sub',
    'ExtraSavingOther': 'Extra Saving Other',
  };

  // 이자 카테고리
  static const interestExpenses = 'InterestExpenses';
  static const interestExpensesSubcategories = {
    'LoanInterest': 'Loan Interest',
  };

  // 모든 카테고리
  static const allCategories = [
    'FixedExpenses',
    'LivingExpenses',
    'InvestmentExpenses',
    'SavingExpenses',
    'InterestExpenses',
  ];

  static const categoryLabels = {
    'FixedExpenses': '고정비',
    'LivingExpenses': '생활비',
    'InvestmentExpenses': '투자',
    'SavingExpenses': '저축',
    'InterestExpenses': '이자',
  };

  static String getCategoryLabel(String category) {
    return categoryLabels[category] ?? category;
  }

  static String getSubcategoryLabel(String category, String subcategory) {
    switch (category) {
      case fixedExpenses:
        return fixedExpensesSubcategories[subcategory] ?? subcategory;
      case livingExpenses:
        return livingExpensesSubcategories[subcategory] ?? subcategory;
      case investmentExpenses:
        return investmentExpensesSubcategories[subcategory] ?? subcategory;
      case savingExpenses:
        return savingExpensesSubcategories[subcategory] ?? subcategory;
      case interestExpenses:
        return interestExpensesSubcategories[subcategory] ?? subcategory;
      default:
        return subcategory;
    }
  }

  static Map<String, String> getSubcategories(String category) {
    switch (category) {
      case fixedExpenses:
        return fixedExpensesSubcategories;
      case livingExpenses:
        return livingExpensesSubcategories;
      case investmentExpenses:
        return investmentExpensesSubcategories;
      case savingExpenses:
        return savingExpensesSubcategories;
      case interestExpenses:
        return interestExpensesSubcategories;
      default:
        return {};
    }
  }

  // 카테고리별 아이콘
  static IconData getCategoryIcon(String subcategory) {
    // 고정비 아이콘
    if (fixedExpensesSubcategories.containsKey(subcategory)) {
      switch (subcategory) {
        case 'CarInsurance':
          return Icons.directions_car;
        case 'CarLoan':
          return Icons.directions_car;
        case 'HealthInsurance':
          return Icons.favorite;
        case 'ManagementFee':
          return Icons.apartment;
        case 'MobileBill':
          return Icons.mobile_friendly;
        case 'RentLease':
          return Icons.home;
        case 'Transportation':
          return Icons.train;
        case 'Utilities':
          return Icons.electrical_services;
        case 'CreditLoan':
          return Icons.credit_card;
        case 'JeonseLoan':
          return Icons.apartment;
        case 'Mortgage':
          return Icons.home;
        default:
          return Icons.receipt;
      }
    }
    // 생활비 아이콘
    else if (livingExpensesSubcategories.containsKey(subcategory)) {
      switch (subcategory) {
        case 'Alcohol':
          return Icons.wine_bar;
        case 'Cigarettes':
          return Icons.smoking_rooms;
        case 'Clothes':
          return Icons.shopping_bag;
        case 'DailyGoods':
          return Icons.shopping_cart;
        case 'Delivery':
          return Icons.local_shipping;
        case 'Drinks':
          return Icons.local_cafe;
        case 'EatingOut':
          return Icons.restaurant;
        case 'Gathering':
          return Icons.people;
        case 'Groceries':
          return Icons.shopping_cart;
        case 'Shoes':
          return Icons.checkroom;
        default:
          return Icons.receipt;
      }
    }
    // 투자 아이콘
    else if (investmentExpensesSubcategories.containsKey(subcategory)) {
      switch (subcategory) {
        case 'PensionSaving':
          return Icons.account_balance;
        case 'IRP':
          return Icons.trending_up;
        default:
          return Icons.trending_up;
      }
    }
    // 저축 아이콘
    else if (savingExpensesSubcategories.containsKey(subcategory)) {
      switch (subcategory) {
        case 'EmergencyFund':
          return Icons.emergency;
        case 'ShortTermGoal':
          return Icons.flag;
        default:
          return Icons.savings;
      }
    }
    // 이자 아이콘
    else if (interestExpensesSubcategories.containsKey(subcategory)) {
      return Icons.percent;
    }

    return Icons.receipt;
  }
}
