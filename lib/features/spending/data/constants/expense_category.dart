import 'package:flutter/material.dart';

// 지출 카테고리
class ExpenseCategory {
  // 생활비 카테고리
  static const livingExpenses = 'LivingExpenses';
  static const livingExpensesSubcategories = {
    'Groceries': '식비',
    'EatingOut': '외식',
    'Delivery': '배달 음식',

    'Coffee': '커피',
    'Drinks': '음료',
    'Alcohol': '술',

    'DailyGoods': '생필품',
    'Cigarettes': '담배',
    'Beauty': '미용',

    'Clothes': '옷',
    'Shoes': '신발',
    'Accessories': '액세서리',

    'Culture': '문화 생활',
    'Gathering': '모임 회비',
    'Hobby': '취미',

    'OTT': 'OTT',
    'Subscription': 'OTT 외\n구독 서비스',
    'Other': '기타',
  };

  // 고정비 카테고리
  static const fixedExpenses = 'FixedExpenses';
  static const fixedExpensesSubcategories = {
    'HealthInsurance': '보험',
    'MobileBill': '통신비',
    'Transportation': '대중교통',
    'CarLoan': '자동차 할부',
    'CarInsurance': '자동차 보험',
    'GasOil': '주유',
    'RentLease': '월세',
    'Utilities': '공과금',
    'ManagementFee': '관리비',
    'Other': '기타',
  };

  // 투자 카테고리
  static const investmentExpenses = 'InvestmentExpenses';
  static const investmentExpensesSubcategories = {
    'PensionSaving': '연금 저축',
    'IRP': '퇴직 연금',
    'ISA': 'ISA',
    'General': '일반계좌',
  };

  // 저축 카테고리
  static const savingExpenses = 'SavingExpenses';
  static const savingExpensesSubcategories = {
    'EmergencyFund': '비상금',
    'ShortTermGoal': '단기 목표',
    'HousingSubscription': '주택 청약',
    'HomeOwnership': '내집 마련',
    'Other': '기타',
  };

  // 이자 카테고리
  static const interestExpenses = 'InterestExpenses';
  static const interestExpensesSubcategories = {
    'CreditLoan': '신용 대출',
    'JeonseLoan': '전세 대출',
    'Mortgage': '주택 담보 대출',
    'Other': '기타 이자',
  };

  // 모든 카테고리
  static const allCategories = [
    'LivingExpenses',
    'FixedExpenses',
    'InvestmentExpenses',
    'SavingExpenses',
    'InterestExpenses',
  ];

  static const categoryLabels = {
    'LivingExpenses': '생활비',
    'FixedExpenses': '고정비',
    'InvestmentExpenses': '투자',
    'SavingExpenses': '저축',
    'InterestExpenses': '이자',
  };

  static String getCategoryLabel(String category) {
    return categoryLabels[category] ?? category;
  }

  static String getSubcategoryLabel(String category, String subcategory) {
    switch (category) {
      case livingExpenses:
        return livingExpensesSubcategories[subcategory] ?? subcategory;
      case fixedExpenses:
        return fixedExpensesSubcategories[subcategory] ?? subcategory;

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
      case livingExpenses:
        return livingExpensesSubcategories;
      case fixedExpenses:
        return fixedExpensesSubcategories;

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
        case 'HealthInsurance':
          return Icons.favorite;
        case 'MobileBill':
          return Icons.mobile_friendly;
        case 'Transportation':
          return Icons.train;

        case 'CarLoan':
          return Icons.car_rental;
        case 'CarInsurance':
          return Icons.directions_car;
        case 'GasOil':
          return Icons.local_gas_station;

        case 'RentLease':
          return Icons.home;
        case 'ManagementFee':
          return Icons.apartment;
        case 'Utilities':
          return Icons.electrical_services;

        default:
          return Icons.receipt;
      }
    }
    // 생활비 아이콘
    else if (livingExpensesSubcategories.containsKey(subcategory)) {
      switch (subcategory) {
        case 'Groceries':
          return Icons.rice_bowl;
        case 'EatingOut':
          return Icons.restaurant;
        case 'Delivery':
          return Icons.motorcycle_outlined;

        case 'Coffee':
          return Icons.coffee;
        case 'Drinks':
          return Icons.local_drink;
        case 'Alcohol':
          return Icons.wine_bar;

        case 'DailyGoods':
          return Icons.shopping_cart;
        case 'Cigarettes':
          return Icons.smoking_rooms;
        case 'Beauty':
          return Icons.brush;

        case 'Clothes':
          return Icons.checkroom;
        case 'Shoes':
          return Icons.shopping_bag;
        case 'Accessories':
          return Icons.watch;

        case 'Culture':
          return Icons.theaters;
        case 'Gathering':
          return Icons.people;
        case 'Hobby':
          return Icons.sports_esports;

        case 'OTT':
          return Icons.tv;
        case 'Subscription':
          return Icons.subscriptions;
        case 'Other':
          return Icons.category;

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
          return Icons.work_rounded;
        case 'ISA':
          return Icons.money;
        case 'General':
          return Icons.trending_up;
        default:
          return Icons.trending_up;
      }
    }
    // 저축 아이콘
    else if (savingExpensesSubcategories.containsKey(subcategory)) {
      switch (subcategory) {
        case 'EmergencyFund':
          return Icons.emergency_recording_rounded;
        case 'ShortTermGoal':
          return Icons.flag;
        case 'HousingSubscription':
          return Icons.home_work;
        case 'HomeOwnership':
          return Icons.house;
        case 'Other':
          return Icons.savings;
        default:
          return Icons.savings;
      }
    }
    // 이자 아이콘
    else if (interestExpensesSubcategories.containsKey(subcategory)) {
      switch (subcategory) {
        case 'CreditLoan':
          return Icons.credit_card;
        case 'JeonseLoan':
          return Icons.apartment;
        case 'Mortgage':
          return Icons.home;

        case 'Other':
          return Icons.percent;
      }
    }

    return Icons.receipt;
  }
}
