import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/helpers/spacing.dart';
import '../../domain/entities/quiz_entity.dart';
import '../widgets/quiz_game_element.dart';

class AddQuizScreen extends StatefulWidget {
  const AddQuizScreen({super.key});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quizTitleController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final List<QuestionEntity> _questions = [];
  QuizTheme previewTheme = QuizTheme.classic;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args.containsKey('quizTheme')) {
      previewTheme = args['quizTheme'] as QuizTheme;
    }
  }

  void _addNewQuestion() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        String questionText = '';
        List<String> options = ['', '', '', ''];
        int correctIndex = 0;
        String correctTextAnswer = '';
        QuestionType selectedType = QuestionType.multipleChoice;

        return StatefulBuilder(
          builder: (context, setLocalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('إضافة سؤال جديد', style: TextStyles.font15DarkBlueMedium.copyWith(fontSize: 18.sp)),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('نوع السؤال:', style: TextStyles.font14GrayRegular),
                          verticalSpace(10),
                          Row(
                            children: [
                              _typeChip('اختيار من متعدد', QuestionType.multipleChoice, selectedType, (t) => setLocalState(() => selectedType = t)),
                              horizontalSpace(10),
                              _typeChip('أكمل الجملة', QuestionType.fillInTheBlanks, selectedType, (t) => setLocalState(() => selectedType = t)),
                            ],
                          ),
                          verticalSpace(20),
                          Text('نص السؤال:', style: TextStyles.font14GrayRegular),
                          verticalSpace(10),
                          TextField(
                            decoration: InputDecoration(hintText: 'اكتب سؤالك هنا...', fillColor: ColorsManager.moreLightGray, filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
                            onChanged: (v) => setLocalState(() => questionText = v),
                          ),
                          verticalSpace(25),
                          if (selectedType == QuestionType.multipleChoice) ...[
                            Text('الاختيارات:', style: TextStyles.font14GrayRegular),
                            ...List.generate(4, (index) => _buildOptionField(index, correctIndex, (idx) => setLocalState(() => correctIndex = idx), (v) => options[index] = v)),
                          ] else ...[
                            Text('الإجابة الصحيحة (نص):', style: TextStyles.font14GrayRegular),
                            verticalSpace(10),
                            TextField(
                              decoration: InputDecoration(hintText: 'اكتب الإجابة التي يجب على الطالب كتابتها...', fillColor: Colors.green.withOpacity(0.05), filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                              onChanged: (v) => setLocalState(() => correctTextAnswer = v),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  verticalSpace(20),
                  ElevatedButton(
                    onPressed: () {
                      if (questionText.isNotEmpty) {
                        _questions.add(QuestionEntity(
                          id: DateTime.now().toString(),
                          questionText: questionText,
                          type: selectedType,
                          options: selectedType == QuestionType.multipleChoice ? options : [],
                          correctAnswerIndex: selectedType == QuestionType.multipleChoice ? correctIndex : -1,
                          correctTextAnswer: selectedType == QuestionType.fillInTheBlanks ? correctTextAnswer : null,
                        ));
                        setState(() {});
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: ColorsManager.mainBlue, minimumSize: Size(double.infinity, 56.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: const Text('حفظ السؤال', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _typeChip(String label, QuestionType type, QuestionType current, Function(QuestionType) onSelected) {
    bool isSelected = type == current;
    return GestureDetector(
      onTap: () => onSelected(type),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(color: isSelected ? ColorsManager.mainBlue : Colors.grey[200], borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 12.sp)),
      ),
    );
  }

  Widget _buildOptionField(int index, int correctIndex, Function(int) onCorrectSelected, Function(String) onChanged) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Radio<int>(value: index, groupValue: correctIndex, onChanged: (v) => onCorrectSelected(v!), activeColor: ColorsManager.mainBlue),
          Expanded(child: TextField(decoration: InputDecoration(hintText: 'الاختيار ${index + 1}'), onChanged: onChanged)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(title: const Text('بناء الاختبار المختلط')),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader(),
              verticalSpace(20),
              _buildQuestionsList(),
              verticalSpace(20),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          TextFormField(controller: _quizTitleController, decoration: const InputDecoration(hintText: 'عنوان الاختبار', border: InputBorder.none)),
          const Divider(),
          TextFormField(controller: _durationController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'المدة بالدقائق', border: InputBorder.none, prefixIcon: Icon(Icons.timer))),
        ],
      ),
    );
  }

  Widget _buildQuestionsList() {
    return Expanded(
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('الأسئلة (${_questions.length})', style: TextStyles.font15DarkBlueMedium),
            TextButton.icon(onPressed: _addNewQuestion, icon: const Icon(Icons.add_circle), label: const Text('إضافة سؤال')),
          ]),
          Expanded(
            child: _questions.isEmpty
                ? const Center(child: Text('ابدأ بإضافة أسئلة متنوعة'))
                : ListView.builder(
                    itemCount: _questions.length,
                    itemBuilder: (context, index) => Card(
                      child: ListTile(
                        leading: Icon(_questions[index].type == QuestionType.multipleChoice ? Icons.list : Icons.edit_note, color: ColorsManager.mainBlue),
                        title: Text(_questions[index].questionText),
                        subtitle: Text(_questions[index].type == QuestionType.multipleChoice ? 'اختيار من متعدد' : 'أكمل: ${_questions[index].correctTextAnswer}'),
                        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _questions.removeAt(index))),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate() && _questions.isNotEmpty) {
          final quiz = QuizEntity(id: DateTime.now().toString(), title: _quizTitleController.text, durationInMinutes: int.parse(_durationController.text), questions: _questions, theme: previewTheme);
          Navigator.pop(context, quiz);
        }
      },
      style: ElevatedButton.styleFrom(backgroundColor: ColorsManager.mainBlue, minimumSize: Size(double.infinity, 56.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      child: const Text('اعتماد الاختبار', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
