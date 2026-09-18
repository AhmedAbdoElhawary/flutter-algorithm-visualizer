/// Arabic table for [AppLocalizations], keyed by the **English source text**
/// exactly as `StringsManager` declares it.
///
/// Three rules decide whether a string belongs here at all:
///
/// 1. **UI chrome is translated.** Labels, captions, buttons, validation
///    messages, empty states — anything the app says in its own voice.
/// 2. **Code is never translated.** Identifiers, file names, language names
///    and anything a learner would retype (`twoSum`, `two_sum.dart`, `Dart`)
///    stay Latin. Translating them would make the app lie about what is on
///    the screen.
/// 3. **A key that is absent is simply not translated.** That is the escape
///    hatch, not a bug — the list at the foot of this file names what is
///    left untranslated on purpose.
///
/// Keys must match the English byte for byte, **including trailing spaces and
/// colons** (`'Time: '`, `'Best:'`), because those are what the call sites
/// concatenate around.
///
/// The 100 problem statements are **not** here. They are data, not chrome, so
/// their Arabic lives in `assets/problems.ar.json` and is merged over the
/// English dataset at load time by `ProblemLocalDataSource`. That overlay
/// carries prose only — description, hints, example explanations — and never
/// anything the offline grader reads, so a correct answer stays correct in
/// either language.
library;

const Map<String, String> kArTranslations = <String, String>{
  // ---------------------------------------------------------------- general
  'Algorithm Visualizer': 'مُصوِّر الخوارزميات',
  'Sorry for inconvenience': 'نعتذر عن الإزعاج',
  'Cancel': 'إلغاء',
  'Unknown page': 'صفحة غير معروفة',
  'Continue': 'متابعة',
  'Save': 'حفظ',
  'Yes': 'نعم',
  'No': 'لا',
  'or': 'أو',
  'and': 'و',
  'All': 'الكل',
  'Status': 'الحالة',
  'Total': 'الإجمالي',
  'View All': 'عرض الكل',
  'Date': 'التاريخ',
  'Result': 'النتيجة',
  'Topics': 'المواضيع',
  'Language': 'اللغة',

  // ------------------------------------------------------- visualizer modes
  'Searching': 'البحث',
  'Sorting': 'الترتيب',

  // Educational one-liners under each algorithm. The names themselves are
  // further down, under "algorithm & CS terms".
  'Swaps like bubbles rising until the biggest reaches the top.':
      'يُبادل العناصر كفقاعات صاعدة حتى يصل الأكبر إلى القمة.',
  'Selects the smallest item each round and fixes its place.': 'يختار أصغر عنصر في كل جولة ويُثبّت موضعه.',
  'Inserts each item into its correct sorted position.': 'يُدرج كل عنصر في موضعه الصحيح داخل الجزء المرتَّب.',
  'Merges divided sorted parts into one ordered list.':
      'يدمج الأجزاء المرتَّبة المقسّمة في قائمة واحدة مرتَّبة.',
  'Quickly partitions data around a chosen pivot value.': 'يقسّم البيانات بسرعة حول قيمة محورية مختارة.',
  'Uses a heap tree to repeatedly extract the largest item.':
      'يستخدم شجرة الكومة لاستخراج أكبر عنصر مرّة بعد مرّة.',
  'Improves insertion sort using distant element gaps.':
      'يُحسّن ترتيب الإدراج باستخدام فجوات متباعدة بين العناصر.',
  'Sorts numbers digit by digit from least to greatest.': 'يرتّب الأرقام خانةً بخانة من الأصغر إلى الأكبر.',
  'Counts occurrences instead of comparing values directly.':
      'يَعُدّ التكرارات بدلًا من مقارنة القيم مباشرة.',
  'Distributes items into buckets, then sorts each bucket.':
      'يوزّع العناصر على سِلال، ثم يرتّب كل سلة على حدة.',
  'Finds the shortest path level by level.': 'يجد أقصر مسار مستوىً بمستوى.',
  'Explores one path deeply before backtracking.': 'يستكشف مسارًا واحدًا بعمق قبل التراجع.',
  'Uses heuristics to quickly find the best path.': 'يستخدم التقديرات الاسترشادية لإيجاد أفضل مسار بسرعة.',

  // ------------------------------------------------- sorting roles & status
  'Initial array - ready to sort': 'المصفوفة الأولية — جاهزة للترتيب',
  '✓ Array fully sorted!': '✓ تم ترتيب المصفوفة بالكامل!',
  'Compare': 'مقارنة',
  'Swap positions': 'تبديل الموضعين',
  'from': 'من',
  'into position': 'إلى الموضع',
  'Swap': 'تبديل',
  'Write': 'كتابة',
  'Sorted': 'مُرتَّب',
  'Minimum': 'الأصغر',
  'Held value': 'القيمة المحجوزة',
  'Pivot': 'المحور',
  'Right run': 'المقطع الأيمن',
  'Left run': 'المقطع الأيسر',
  'Target': 'الهدف',
  'Boundary': 'الحد',
  'Base': 'الأساس',
  'Min': 'الأصغر',
  'Held': 'محجوز',
  'Reset': 'إعادة تعيين',

  // Complexity table. The trailing space / colon is part of the key.
  'Time: ': 'الزمن: ',
  'Space: ': 'الذاكرة: ',
  'Best:': 'الأفضل:',
  'Stable:': 'مستقر:',

  // ----------------------------------------------- searching roles & status
  'Start': 'البداية',
  'End': 'النهاية',
  'Searcher': 'الباحث',
  'Visited': 'مُستكشَف',
  'Path': 'المسار',
  'Wall': 'جدار',
  'Oldest first': 'الأقدم أولًا',
  'Newest first': 'الأحدث أولًا',
  'Cheapest first': 'الأقل تكلفة أولًا',
  'waiting': 'في الانتظار',
  'depth': 'العمق',
  'cost': 'التكلفة',
  'to go': 'متبقٍ',
  'Path found': 'تم إيجاد المسار',
  'steps': 'خطوة',
  '(not the shortest)': '(ليس الأقصر)',
  'No path — every reachable cell explored': 'لا يوجد مسار — تم استكشاف كل خلية يمكن الوصول إليها',
  'Drag cells to draw walls, then press Run': 'اسحب الخلايا لرسم الجدران، ثم اضغط تشغيل',
  'Step {current} of {total}': 'الخطوة {current} من {total}',
  'Step': 'الخطوة',
  'Clear walls': 'مسح الجدران',
  'Random walls': 'جدران عشوائية',

  // ------------------------------------------------------------- challenges
  'Challenges': 'التحديات',
  'Practice': 'تدرَّب',
  'Easy': 'سهل',
  'Medium': 'متوسط',
  'Hard': 'صعب',
  'Search problems…': 'ابحث في المسائل…',
  'No problems found': 'لا توجد مسائل',
  'Try a different search or filter': 'جرّب بحثًا أو تصفيةً مختلفة',
  'Not able to load any challenge...': 'تعذّر تحميل أي تحدٍّ...',
  'Try in different time': 'حاول في وقت آخر',
  'No challenge selected': 'لم يتم اختيار أي تحدٍّ',
  'Solve →': 'حلّ ←',
  'Solve in editor': 'حلّ في المحرّر',
  'Problems': 'مسائل',
  'Problem': 'مسألة',
  'solved': 'محلولة',
  'Solved': 'تم الحل',
  'Not Solved': 'غير محلولة',
  'Attempted': 'قيد المحاولة',
  'Hints': 'تلميحات',
  'Similar Questions': 'مسائل مشابهة',
  'No hints yet': 'لا توجد تلميحات بعد',
  'No similar questions yet': 'لا توجد مسائل مشابهة بعد',
  'Dart only for now': 'لغة Dart فقط حاليًا',

  // ------------------------------------------------------------- the editor
  'Running...': 'جارٍ التشغيل...',
  'Input': 'المُدخل',
  'Output': 'المُخرَج',
  'Example': 'مثال',
  'Constraints': 'القيود',
  'Passed': 'نجح',
  'Failed': 'فشل',
  '▸ Run & submit': '▸ تشغيل وإرسال',
  'TEST CASES': 'حالات الاختبار',
  '→ got ': '← الناتج ',

  // Celebration. Composed as `all` + count + ` test cases passed`, so the two
  // halves are translated to wrap the number the same way Arabic would.
  'all ': 'نجحت ',
  ' test cases passed': ' حالة اختبار',
  'Next problem': 'المسألة التالية',
  'See the visual trace': 'شاهد التتبّع المرئي',

  // ---------------------------------------------------------------- profile
  'Profile': 'الملف الشخصي',
  'Day\nStreak': 'أيام\nمتتالية',
  'Accuracy\nRate': 'نسبة\nالدقة',
  'Bookmarked': 'حفظ',
  'Activity (12 weeks)': 'النشاط (12 أسبوعًا)',
  'This Week': 'هذا الأسبوع',
  'Less': 'أقل',
  'More': 'أكثر',
  'days': 'أيام',
  'Streak': 'التتابع',
  'Accuracy': 'الدقة',
  'Attempts': 'المحاولات',
  'Submissions': 'مُرسَلات',
  'Submission': 'مُرسَلة',
  'Solved Topics': 'المواضيع المحلولة',
  'Difficulty Progress': 'التقدّم حسب الصعوبة',
  'Practice History': 'سجلّ التدريب',
  'Recent Activity': 'النشاط الأخير',
  'Anonymous': 'مستخدم مجهول',
  'Continue Learning': 'واصل التعلّم',

  // Bookmarks / history lists.
  'Swipe a row to remove it from bookmarks.': 'اسحب الصف لإزالته من المحفوظات.',
  'That is the whole bookmarks': 'هذه كل المحفوظات',
  'That is the whole history': 'هذا كل السجلّ',
  'Long press on the card to jump to the problem': 'اضغط مطوّلًا على البطاقة للانتقال إلى المسألة',
  'last': 'آخر',

  // Relative time. These attach to a number, so each keeps a leading space.
  'Just now': 'الآن',
  'Yesterday': 'أمس',
  'm ago': ' دقيقة',
  'h ago': ' ساعة',
  'd ago': ' يوم',
  'day ago': 'يوم مضى',
  'days ago': 'أيام مضت',

  // ------------------------------------------------------------------- home
  'Home': 'الرئيسية',
  'Visual': 'مرئي',
  'Code': 'الكود',
  'Good morning': 'صباح الخير',
  'Good afternoon': 'مساء الخير',
  'Good evening': 'مساء الخير',

  // ------------------------------------------------------------------- auth
  'Welcome': 'أهلًا',
  'Sign in to keep your streak and pick up where you stopped.':
      'سجّل الدخول للحفاظ على تتابعك ومواصلة ما توقفت عنده.',
  'Email': 'البريد الإلكتروني',
  'Password': 'كلمة المرور',
  'Forgot?': 'نسيتها؟',
  'Sign in': 'تسجيل الدخول',
  'Not have account yet?': 'ليس لديك حساب بعد؟',
  'Already have an account?': 'لديك حساب بالفعل؟',
  'Sign up': 'إنشاء حساب',
  'Create account': 'إنشاء حساب',
  'Track every problem you solve and build a streak worth keeping.':
      'تابع كل مسألة تحلّها وابْنِ تتابعًا يستحق الاستمرار.',
  'Full name': 'الاسم الكامل',
  'Confirm password': 'تأكيد كلمة المرور',
  'Re-enter password': 'أعد إدخال كلمة المرور',

  // Password strength meter.
  'Weak': 'ضعيفة',
  'Fair': 'مقبولة',
  'Good': 'جيدة',
  'Strong': 'قوية',
  'add a few more characters': 'أضف بضعة أحرف أخرى',
  'add a number to strengthen it': 'أضف رقمًا لتقويتها',
  'mix upper and lower case': 'اخلط بين الأحرف الكبيرة والصغيرة',
  'add a symbol to strengthen it': 'أضف رمزًا لتقويتها',
  'strong enough to keep': 'قوية بما يكفي',
  'Use at least 8 characters.': 'استخدم 8 أحرف على الأقل.',

  // Account recovery.
  'ACCOUNT RECOVERY': 'استعادة الحساب',
  'Resend email link': 'إعادة إرسال الرابط',
  'Check your email': 'تحقّق من بريدك',
  "Didn't receive the link? Check your spam folder or request a new link in":
      'لم يصلك الرابط؟ تحقّق من مجلد الرسائل غير المرغوبة أو اطلب رابطًا جديدًا خلال',
  'Reset your password': 'إعادة تعيين كلمة المرور',
  'We sent a password reset link to': 'أرسلنا رابط إعادة تعيين كلمة المرور إلى',
  'Check your inbox and follow the link to create a new password.':
      'تحقّق من بريدك واتبع الرابط لإنشاء كلمة مرور جديدة.',
  'Enter the email on your account and, and you will get the changing password link.':
      'أدخل البريد الإلكتروني المرتبط بحسابك، وسيصلك رابط تغيير كلمة المرور.',
  'Registered email': 'البريد المُسجَّل',
  'The code expires after 10 minutes.': 'تنتهي صلاحية الرمز بعد 10 دقائق.',
  'Send link': 'إرسال الرابط',
  'Return to sign in': 'العودة لتسجيل الدخول',
  'New Password': 'كلمة المرور الجديدة',
  'Enter new password': 'أدخل كلمة المرور الجديدة',
  'Confirm New Password': 'تأكيد كلمة المرور الجديدة',
  'Re-enter new password': 'أعد إدخال كلمة المرور الجديدة',

  // Validation and status messages.
  'Please enter your name': 'يُرجى إدخال اسمك',
  'Please enter a valid name': 'يُرجى إدخال اسم صالح',
  'Name must be at least 2 characters': 'يجب ألّا يقل الاسم عن حرفين',
  'Please enter your email': 'يُرجى إدخال بريدك الإلكتروني',
  'Please enter a valid email address': 'يُرجى إدخال بريد إلكتروني صالح',
  'Please enter your password': 'يُرجى إدخال كلمة المرور',
  'Password must be at least 6 characters': 'يجب ألّا تقل كلمة المرور عن 6 أحرف',
  'Please confirm your password': 'يُرجى تأكيد كلمة المرور',
  'Passwords do not match': 'كلمتا المرور غير متطابقتين',
  'Verification code must be 6 digits': 'يجب أن يتكوّن رمز التحقق من 6 أرقام',
  'Welcome back!': 'أهلًا بعودتك!',
  'Account created successfully!': 'تم إنشاء الحساب بنجاح!',
  'Verification code sent to your email': 'تم إرسال رمز التحقق إلى بريدك',
  'Invalid email or password': 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
  'An account with this email already exists': 'يوجد حساب مسجَّل بهذا البريد بالفعل',
  'No account found with this email': 'لا يوجد حساب مرتبط بهذا البريد',
  'Network error. Please try again': 'خطأ في الشبكة. يُرجى المحاولة مرة أخرى',

  // ------------------------------------------------------- account settings
  'Display name updated successfully': 'تم تحديث الاسم المعروض بنجاح',
  'Password updated successfully': 'تم تحديث كلمة المرور بنجاح',
  'Please log in again before making this change': 'يُرجى تسجيل الدخول مجددًا قبل إجراء هذا التغيير',
  'Please enter your current password': 'يُرجى إدخال كلمة المرور الحالية',
  'Please enter a display name': 'يُرجى إدخال اسم معروض',
  'Please enter a new email': 'يُرجى إدخال بريد إلكتروني جديد',
  'Please enter a new password': 'يُرجى إدخال كلمة مرور جديدة',

  'Change password': 'تغيير كلمة المرور',
  'Update the password you sign in with.': 'حدّث كلمة المرور التي تسجّل الدخول بها.',
  'Change your password': 'غيّر كلمة المرور',
  'Confirm your current password, then choose a new one.': 'أكّد كلمة المرور الحالية، ثم اختر واحدة جديدة.',
  'Current password': 'كلمة المرور الحالية',
  'Your password today': 'كلمة مرورك الحالية',
  'Pick a password different from your current one': 'اختر كلمة مرور مختلفة عن الحالية',

  'Display name': 'الاسم المعروض',
  'Change your name': 'غيّر اسمك',
  'This is the name shown on your profile. It changes nothing about how you sign in.':
      'هذا هو الاسم الظاهر في ملفك الشخصي. لا يؤثر إطلاقًا على طريقة تسجيل دخولك.',
  'Name': 'الاسم',
  'How you want to be called': 'الاسم الذي تريد أن تُنادى به',
  'This is already your name': 'هذا اسمك بالفعل',

  'Change email': 'تغيير البريد الإلكتروني',
  'Move your account to a different inbox.': 'انقل حسابك إلى بريد إلكتروني آخر.',
  'Change your email': 'غيّر بريدك الإلكتروني',
  'We send a confirmation link to the new address. Your email changes only after you open that link.':
      'نرسل رابط تأكيد إلى العنوان الجديد. لا يتغيّر بريدك إلا بعد فتح ذلك الرابط.',
  'New email': 'البريد الإلكتروني الجديد',
  'This is already your email': 'هذا بريدك الإلكتروني بالفعل',
  'Confirmation link sent. Open it from your new inbox, then sign in again with the new email.':
      'تم إرسال رابط التأكيد. افتحه من بريدك الجديد، ثم سجّل الدخول مرة أخرى بالبريد الجديد.',

  // Logout.
  'Log Out': 'تسجيل الخروج',
  'Log out of your account?': 'تسجيل الخروج من حسابك؟',

  // ------------------------------------------------------------------- sync
  'Sync your progress': 'مزامنة تقدّمك',
  'Your progress is up to date.': 'تقدّمك محدّث الآن.',
  'Could not sync. Check your connection and try again.':
      'تعذّرت المزامنة. تحقّق من اتصالك وحاول مرة أخرى.',
  'Just a moment': 'لحظة من فضلك',
  'Got it': 'حسنًا',
  'Sync your data': 'زامن بياناتك',
  'Syncing is limited to once every 30 seconds. You can sync again in {seconds}s.':
      'المزامنة متاحة مرة كل ٣٠ ثانية. يمكنك المزامنة مرة أخرى بعد {seconds} ثانية.',
  'You can sign back in anytime to continue your algorithmic journey.':
      'يمكنك تسجيل الدخول في أي وقت لمواصلة رحلتك مع الخوارزميات.',

  // --------------------------------------------------------------- settings
  'Settings': 'الإعدادات',
  'Account': 'الحساب',
  'Appearance': 'المظهر',
  'System': 'النظام',
  "Match your phone's setting": 'يتبع إعداد هاتفك',
  'Light': 'فاتح',
  'Always light': 'فاتح دائمًا',
  'Dark': 'داكن',
  'Always dark': 'داكن دائمًا',
  'Legal': 'الشؤون القانونية',
  'About': 'حول التطبيق',
  'Contact': 'التواصل',
  'Signed in as': 'مسجَّل الدخول باسم',
  'Privacy Policy': 'سياسة الخصوصية',
  'What AlgoDive stores, and why.': 'ما الذي يحفظه AlgoDive، ولماذا.',
  'Terms of Service': 'شروط الخدمة',
  'The rules for using AlgoDive.': 'قواعد استخدام AlgoDive.',
  'Source code': 'الكود',
  'AlgoDive is open source on GitHub.': 'AlgoDive مفتوح المصدر على GitHub.',
  'Version': 'الإصدار',
  'Policy version': 'إصدار السياسة',
  'Email support': 'التواصل عبر البريد',
  'Follow the project and the author.': 'تابع المشروع والمطوّر.',
  'Connect with the developer.': 'تواصل مع المطوّر.',

  // Delete account.
  'Delete account': 'حذف الحساب',
  'Permanently erase your account and all its data.': 'امحُ حسابك وكل بياناته نهائيًا.',
  'Delete your account?': 'حذف حسابك؟',
  'Your solved problems, streak and statistics will be erased for everyone and forever. This cannot be undone.':
      'ستُمحى المسائل التي حللتها وتتابعك وإحصاءاتك للجميع وإلى الأبد. لا يمكن التراجع عن هذا.',
  "Confirm it's you": 'أكّد هويتك',
  'Enter your password to permanently delete this account.': 'أدخل كلمة المرور لحذف هذا الحساب نهائيًا.',
  'Delete Forever': 'حذف نهائي',
  'Your account has been deleted.': 'تم حذف حسابك.',
  "Can't sign in? Request deletion by email instead":
      'لا تستطيع تسجيل الدخول؟ اطلب الحذف عبر البريد بدلًا من ذلك',
  'How deletion works': 'كيف يتم الحذف',
  'What is erased, and how to request it by email.': 'ما الذي يُمحى، وكيف تطلبه عبر البريد.',

  // Opening an external link.
  "Couldn't open that link": 'تعذّر فتح هذا الرابط',
  'No mail app is set up on this device': 'لا يوجد تطبيق بريد مُعَدّ على هذا الجهاز',

  // Sign-up consent.
  'By creating an account, you agree to our': 'بإنشائك حسابًا، فإنك توافق على',

  // ----------------------------------------------------------- guest access
  'Replace your local progress?': 'استبدال تقدّمك المحلي؟',
  'Your local interactions will be removed when you log in to this account.':
      'ستُحذف بياناتك المحلية عند تسجيل الدخول إلى هذا الحساب.',
  'Log In Anyway': 'سجّل الدخول على أي حال',
  'Log In or Sign Up': 'تسجيل الدخول أو إنشاء حساب',
  'Save your progress and sync it across your devices.': 'احفظ تقدّمك وزامنه بين أجهزتك.',

  // ------------------------------------------------------------- onboarding
  'Skip': 'تخطّي',
  'Next': 'التالي',
  'Get started': 'ابدأ الآن',
  'Continue as guest': 'المتابعة كضيف',
  'Guest progress moves to your account later': 'ينتقل تقدّم الضيف إلى حسابك لاحقًا',
  'Algorithms, one step at a time.': 'الخوارزميات، خطوةً بخطوة.',
  'Every comparison and swap, shown as it happens.': 'كل مقارنة وكل تبديل، تراه لحظة حدوثه.',
  'Draw a maze. Watch it get solved.': 'ارسم متاهة. وشاهد كيف تُحَلّ.',
  'Drag walls, then watch the search find its way through.': 'اسحب الجدران، ثم شاهد البحث وهو يشقّ طريقه.',
  '100 challenges. Graded offline.': '100 تحدٍّ. تُصحَّح دون إنترنت.',
  'Your code runs on your device. Nothing leaves it.': 'كودك يعمل على جهازك. لا شيء يغادره.',
  'Graded on this device · no network': 'التصحيح على هذا الجهاز · بلا إنترنت',
  ' passed': ' ناجحة',
  'See your streak grow.': 'شاهد تتابعك ينمو.',
  'Every solved problem lands on the grid the same day.': 'كل مسألة تحلّها تظهر على الشبكة في اليوم نفسه.',
  'day streak': 'يوم متتالٍ',

  // ------------------------------------------------ algorithm & CS terms
  //
  // House style: **Arabic first, English in brackets.** A learner reading in
  // Arabic still has to recognise the term they will meet in an interview, in
  // a lecture and in every search result — so the English is kept, but as a
  // gloss rather than as the label. Acronyms (BFS, DFS) and people's names
  // (Shell, Dijkstra) stay Latin inside the brackets for the same reason.
  'Bubble sort': 'الترتيب الفقاعي (Bubble Sort)',
  'Insertion sort': 'ترتيب الإدراج (Insertion Sort)',
  'Selection sort': 'ترتيب الاختيار (Selection Sort)',
  'Merge sort': 'ترتيب الدمج (Merge Sort)',
  'Heap sort': 'ترتيب الكومة (Heap Sort)',
  'Quick sort': 'الترتيب السريع (Quick Sort)',
  'Radix sort': 'ترتيب الجذر (Radix Sort)',
  'Shell sort': 'ترتيب شِل (Shell Sort)',
  'Counting sort': 'ترتيب العدّ (Counting Sort)',
  'Bucket sort': 'ترتيب السِّلال (Bucket Sort)',
  // The three searching labels share one 360pt row, three `Expanded` cells
  // wide — about 84pt of text each. The bracketed form used everywhere else
  // ("البحث بالعرض (BFS)") does not fit, and an ellipsis in the middle of an
  // acronym is worse than no translation. So here the acronym carries the
  // meaning and only the word around it is translated. It also comes out
  // *shorter* than the English it replaces.
  'A* Search': 'بحث ‎A*‎',
  'BFS Search': 'بحث BFS',
  'DFS Search': 'بحث DFS',

  // ------------------------------------------------------ run-time failures
  //
  // Each `{placeholder}` is filled in after this string is chosen, so the
  // Arabic can put the number or the identifier wherever Arabic wants it.
  '{kind} error (line {line}): {message}': 'خطأ {kind} (السطر {line}): {message}',
  'syntax': 'صياغة',
  'runtime': 'تشغيل',
  'unsupported': 'غير مدعوم',
  'time limit': 'مهلة زمنية',
  'memory limit': 'حدّ الذاكرة',
  'recursion limit': 'حدّ الاستدعاء الذاتي',
  'cancelled': 'إلغاء',

  "Undefined variable '{name}'": "متغيّر غير معرّف: '{name}'",
  "Undefined function '{name}'": "دالّة غير معرّفة: '{name}'",
  'Index {index} is out of range for a list of length {length}':
      'الموضع {index} خارج نطاق قائمة طولها {length}',
  "Key '{key}' was not found": "المفتاح '{key}' غير موجود",
  'Division by zero': 'القسمة على صفر',
  'Expected {expected} but got {actual}': 'كان المتوقَّع {expected} والناتج {actual}',
  'Expected {expected} argument(s) but got {actual}': 'كان المتوقَّع {expected} مُعامِلًا والناتج {actual}',
  'Uncaught error: {message}': 'خطأ غير مُعالَج: {message}',
  "'{construct}' isn't supported in this editor yet": "'{construct}' غير مدعوم في هذا المحرّر بعد",
  "'{name}' isn't available in this environment": "'{name}' غير متاح في هذه البيئة",
  'This line mixes tabs and spaces, so its indentation is ambiguous':
      'يخلط هذا السطر بين المسافات وعلامات الجدولة، فأصبحت مسافته البادئة ملتبسة',
  "This line's indentation doesn't line up with any block above it":
      'المسافة البادئة لهذا السطر لا تطابق أي كتلة فوقه',
  'Inconsistent indentation': 'مسافة بادئة غير متناسقة',
  'This problem uses a linked list or tree, which the editor can only build in Dart so far':
      'تستخدم هذه المسألة قائمة مترابطة أو شجرة، ولا يستطيع المحرّر بناءها إلا بلغة Dart حتى الآن',
  "Couldn't find a function named '{name}' to run": "لم يُعثر على دالّة باسم '{name}' لتشغيلها",
  'This ran for too long and was stopped': 'استغرق التنفيذ وقتًا طويلًا فتم إيقافه',
  'This used too much memory and was stopped': 'استهلك التنفيذ ذاكرة أكثر من اللازم فتم إيقافه',
  'This recursed too deeply and was stopped': 'تعمّق الاستدعاء الذاتي أكثر من اللازم فتم إيقافه',
  'Cancelled': 'أُلغي',
  'Something went wrong while running this code': 'حدث خطأ ما أثناء تشغيل هذا الكود',

  // Deliberately NOT translatable, and should stay that way:
  //   'AlgoDive', 'Dart', 'GitHub', 'LinkedIn', 'NAN', '(i)', '(j)', ' · ',
  //   'two_sum.dart', 'twoSum', 'name@example.com', '••••••••',
  //   'Ahmed Elhawary', 'Made by Ahmed Abdo Elhawary'
  // — names, identifiers and punctuation. See rule 2 in the header.
  //
  // Problem *names* ("Two Sum", "Valid Parentheses") are also deliberately
  // English, and live in `problems.json` rather than here. They are what the
  // challenges search box matches on, and what a learner types into LeetCode
  // to find the same problem; an Arabic title would break both.
};
