import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/helpers/spacing.dart';
import '../../domain/entities/quiz_entity.dart';

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

  void _addNewQuestion() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        String questionText = '';
        List<String> options = ['', '', '', ''];
        int correctIndex = 0;

        return StatefulBuilder(
          builder: (context, setState) {
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
                          Text('نص السؤال:', style: TextStyles.font14GrayRegular),
                          verticalSpace(10),
                          TextField(
                            maxLines: 5,
                            minLines: 3,
                            decoration: InputDecoration(
                              hintText: 'اكتب سؤالك هنا بوضوح...',
                              fillColor: ColorsManager.moreLightGray,
                              filled: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                            ),
                            onChanged: (v) => questionText = v,
                          ),
                          verticalSpace(30),
                          Text('الاختيارات والإجابة الصحيحة:', style: TextStyles.font14GrayRegular),
                          verticalSpace(10),
                          ...List.generate(4, (index) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 12.h),
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              decoration: BoxDecoration(
                                color: correctIndex == index ? ColorsManager.mainBlue.withOpacity(0.05) : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: correctIndex == index ? ColorsManager.mainBlue : ColorsManager.lighterGray),
                              ),
                              child: Row(
                                children: [
                                  Radio<int>(
                                    value: index,
                                    groupValue: correctIndex,
                                    onChanged: (v) => setState(() => correctIndex = v!),
                                    activeColor: ColorsManager.mainBlue,
                                  ),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'الاختيار ${index + 1}',
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (v) => options[index] = v,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  verticalSpace(20),
                  ElevatedButton(
                    onPressed: () {
                      if (questionText.isNotEmpty && options.every((element) => element.isNotEmpty)) {
                        _questions.add(QuestionEntity(
                          id: DateTime.now().toString(),
                          questionText: questionText,
                          options: options,
                          correctAnswerIndex: correctIndex,
                        ));
                        this.setState(() {}); // Update main screen
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsManager.mainBlue,
                      minimumSize: Size(double.infinity, 56.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('حفظ السؤال في القائمة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('بناء الاختبار'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _quizTitleController,
                      decoration: const InputDecoration(hintText: 'عنوان الاختبار (مثلاً: مراجعة الوحدة الأولى)', border: InputBorder.none),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                    ),
                    const Divider(),
                    TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'مدة الاختبار بالدقائق', border: InputBorder.none, prefixIcon: Icon(Icons.timer_outlined)),
                      validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                    ),
                  ],
                ),
              ),
              verticalSpace(25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الأسئلة المُضافة (${_questions.length})', style: TextStyles.font15DarkBlueMedium),
                  TextButton.icon(
                    onPressed: _addNewQuestion,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('إضافة سؤال جديد'),
                  ),
                ],
              ),
              verticalSpace(10),
              Expanded(
                child: _questions.isEmpty
                    ? Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.quiz_outlined, size: 60.w, color: ColorsManager.lightGray),
                          const Text('لم تقم بإضافة أسئلة بعد'),
                        ],
                      ))
                    : ListView.builder(
                        itemCount: _questions.length,
                        itemBuilder: (context, index) {
                          return FadeInRight(
                            child: Card(
                              margin: EdgeInsets.only(bottom: 12.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: ListTile(
                                leading: CircleAvatar(backgroundColor: ColorsManager.mainBlue.withOpacity(0.1), child: Text('${index + 1}')),
                                title: Text(_questions[index].questionText, maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Text('صح: ${_questions[index].options[_questions[index].correctAnswerIndex]}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => setState(() => _questions.removeAt(index)),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              verticalSpace(20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _questions.isNotEmpty) {
                    final quiz = QuizEntity(
                      id: DateTime.now().toString(),
                      title: _quizTitleController.text,
                      durationInMinutes: int.parse(_durationController.text),
                      questions: _questions,
                    );
                    Navigator.pop(context, quiz);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.mainBlue,
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('اعتماد وحفظ الاختبار النهائي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
