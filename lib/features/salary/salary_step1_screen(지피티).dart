// import 'package:flutter/material.dart';

// class SalaryStep1Screen extends StatefulWidget {
//   const SalaryStep1Screen({super.key});

//   @override
//   _SalaryStep1ScreenState createState() => _SalaryStep1ScreenState();
// }

// class _SalaryStep1ScreenState extends State<SalaryStep1Screen> {
//   DateTime _currentDate = DateTime(2025, 8);
//   bool _hasShortTermGoal = false;

//   final TextEditingController _currentAgeController = TextEditingController();
//   final TextEditingController _livingExpenseController =
//       TextEditingController();
//   final TextEditingController _snpValuationController = TextEditingController();
//   final TextEditingController _retireAgeController = TextEditingController();
//   final TextEditingController _expectedReturnController =
//       TextEditingController();
//   final TextEditingController _expectedInflationController =
//       TextEditingController();

//   // Short-term goal controllers
//   String _selectedGoalType = '';
//   final TextEditingController _goalAmountController = TextEditingController();
//   final TextEditingController _goalDurationController = TextEditingController();
//   final TextEditingController _currentSavingsController =
//       TextEditingController();

//   final List<String> _goalTypes = ['Marriage', 'Travel', 'Car', 'Other'];

//   void _goToPreviousMonth() {
//     setState(() {
//       _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
//     });
//   }

//   void _goToNextMonth() {
//     setState(() {
//       _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
//     });
//   }

//   @override
//   void dispose() {
//     _currentAgeController.dispose();
//     _livingExpenseController.dispose();
//     _snpValuationController.dispose();
//     _retireAgeController.dispose();
//     _expectedReturnController.dispose();
//     _expectedInflationController.dispose();
//     _goalAmountController.dispose();
//     _goalDurationController.dispose();
//     _currentSavingsController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     String monthYear =
//         "${_getMonthName(_currentDate.month)} ${_currentDate.year}";

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Salary Optimization - Step 1'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // Month Selector
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.chevron_left),
//                   onPressed: _goToPreviousMonth,
//                 ),
//                 Text(
//                   monthYear,
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.chevron_right),
//                   onPressed: _goToNextMonth,
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),

//             _buildInputField('Current Age', _currentAgeController),
//             _buildInputField(
//               'Desired Monthly Living Expenses (\$)',
//               _livingExpenseController,
//             ),
//             _buildInputField(
//               'Current S&P500 Valuation (\$)',
//               _snpValuationController,
//             ),
//             _buildInputField('Desired Retirement Age', _retireAgeController),
//             _buildInputField(
//               'Expected Return Rate (%)',
//               _expectedReturnController,
//             ),
//             _buildInputField(
//               'Expected Inflation Rate (%)',
//               _expectedInflationController,
//             ),

//             SizedBox(height: 20),
//             _buildToggleShortTermGoal(),

//             if (_hasShortTermGoal) ...[
//               SizedBox(height: 20),
//               _buildDropdownGoalType(),
//               _buildInputField('Goal Amount (\$)', _goalAmountController),
//               _buildInputField(
//                 'Goal Duration (months)',
//                 _goalDurationController,
//               ),
//               _buildInputField(
//                 'Current Savings for this Goal (\$)',
//                 _currentSavingsController,
//               ),
//             ],

//             SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () {
//                 // TODO: Navigate to Step 2
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black,
//                 padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
//               ),
//               child: Text('Next', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInputField(String label, TextEditingController controller) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label),
//           SizedBox(height: 8),
//           TextField(
//             controller: controller,
//             keyboardType: TextInputType.numberWithOptions(decimal: true),
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: Colors.grey[200],
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildToggleShortTermGoal() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text("Do you have a short-term goal?"),
//         Switch(
//           value: _hasShortTermGoal,
//           onChanged: (value) {
//             setState(() {
//               _hasShortTermGoal = value;
//             });
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildDropdownGoalType() {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Goal Type'),
//           SizedBox(height: 8),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12),
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: DropdownButton<String>(
//               value: _selectedGoalType.isEmpty ? null : _selectedGoalType,
//               hint: Text("Select goal type"),
//               isExpanded: true,
//               underline: SizedBox(),
//               items: _goalTypes.map((String type) {
//                 return DropdownMenuItem<String>(value: type, child: Text(type));
//               }).toList(),
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedGoalType = newValue!;
//                 });
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getMonthName(int month) {
//     const List<String> monthNames = [
//       "January",
//       "February",
//       "March",
//       "April",
//       "May",
//       "June",
//       "July",
//       "August",
//       "September",
//       "October",
//       "November",
//       "December",
//     ];
//     return monthNames[month - 1];
//   }
// }
