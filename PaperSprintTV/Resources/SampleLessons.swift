import Foundation

/// Original local revision material; not an official SLIIT examination paper.
enum LearningCatalog {
    static let subjects = [
        Subject(id: "swift", name: "Swift Foundations", subtitle: "Build your language confidence", icon: "swift"),
        Subject(id: "swiftui", name: "SwiftUI Essentials", subtitle: "Think in views and state", icon: "rectangle.3.group"),
        Subject(id: "ios", name: "iOS Development", subtitle: "Data, quality and Apple frameworks", icon: "iphone")
    ]
    static let lessons: [Lesson] = [
        Lesson(id: "values", subjectID: "swift", title: "Values, Types & Optionals", minutes: 5,
            introduction: "Understand how Swift stores information and represents missing values.", sections: [
                LessonSection(heading: "Constants and variables", body: "Use let for a value that will not be reassigned. Use var when the value must change. Swift infers types from initial values, or you can write a type annotation such as var mark: Int = 75.\n\nlet module = \"SE4041\"\nvar attempts = 0\nattempts += 1"),
                LessonSection(heading: "Choose a suitable type", body: "Int represents whole numbers. Double represents floating-point values. String stores text, and Bool stores true or false. Swift does not implicitly convert an Int variable into a Double; convert explicitly when needed.\n\nlet average = Double(total) / Double(count)"),
                LessonSection(heading: "Handle missing values safely", body: "String? can hold a String or nil. Use if let or guard let to unwrap an optional safely. The nil-coalescing operator ?? supplies a fallback. Force-unwrapping with ! will trap if the value is nil.\n\nlet nickname: String? = nil\nlet greeting = nickname ?? \"Student\"")]),
        Lesson(id: "functions", subjectID: "swift", title: "Functions, Collections & Types", minutes: 6,
            introduction: "Organise reusable logic and choose data structures deliberately.", sections: [
                LessonSection(heading: "Functions and early validation", body: "Define a function with func. Parameters accept input, and -> describes the return type. Argument labels make calls readable. A guard statement handles an invalid case first and must leave its scope in the else branch.\n\nfunc doubled(_ value: Int) -> Int {\n    return value * 2\n}"),
                LessonSection(heading: "Transform collections", body: "Arrays preserve element order and can contain duplicates. Sets contain unique values. Dictionaries associate keys with values. filter selects matching elements, map transforms each element, and reduce combines values.\n\nlet passed = marks.filter { $0 >= 50 }\nlet total = marks.reduce(0, +)"),
                LessonSection(heading: "Value and reference semantics", body: "A struct is a value type: assigning it to another variable creates an independent value. A class is a reference type: multiple variables can refer to one instance. Enums describe a fixed set of related cases. A struct method that changes stored properties must be marked mutating.")]),
        Lesson(id: "views", subjectID: "swiftui", title: "Views, Layout & Components", minutes: 5,
            introduction: "Describe an interface as a composition of small views.", sections: [
                LessonSection(heading: "A declarative interface", body: "A SwiftUI view describes the interface for the current state. A typical screen is a struct conforming to View. Its body is a computed property that returns some View. When observed state changes, SwiftUI updates the relevant interface."),
                LessonSection(heading: "Build a layout", body: "VStack arranges children vertically. HStack arranges them horizontally. ZStack layers them. ScrollView allows content to move when it exceeds the available space. LazyVGrid can adapt cards to the available width."),
                LessonSection(heading: "Reuse and adapt", body: "Extract repeated UI into small custom views. A ViewModifier applies reusable styling or behaviour. Use semantic fonts such as .headline and .body for Dynamic Type. Semantic foreground and background colours help the interface adapt to Dark Mode.")]),
        Lesson(id: "state", subjectID: "swiftui", title: "State, Binding & Navigation", minutes: 5,
            introduction: "Connect user actions to data and move between screens.", sections: [
                LessonSection(heading: "Local view state", body: "@State owns transient view state, such as a selected answer. It should not be treated as durable storage: recreating a view or terminating the app can discard transient state. A single source of truth keeps the interface consistent."),
                LessonSection(heading: "Pass editable values", body: "@Binding gives a child view a read/write connection to state owned elsewhere. A binding does not create another independent source of truth. Use a binding when a child control needs to update its parent's value."),
                LessonSection(heading: "Navigation and presentation", body: "NavigationStack manages a stack of destinations. NavigationLink pushes a destination. A sheet presents a temporary flow, such as settings. Keep navigation deliberate and protect users from accidentally abandoning an unfinished quiz.")]),
        Lesson(id: "persistence", subjectID: "ios", title: "Persistence & Data Flow", minutes: 5,
            introduction: "Keep useful information available after the app closes.", sections: [
                LessonSection(heading: "SwiftData", body: "The @Model macro defines a persistent model. ModelContainer manages storage for a schema. ModelContext inserts, fetches, changes and deletes models. In SwiftUI, @Query fetches models and reacts to observed changes."),
                LessonSection(heading: "Save and handle errors", body: "Call try context.save() when you need to confirm a write. Handle errors visibly instead of reporting success. Roll back failed pending changes where appropriate. A persistence test should save data, reopen its store and verify values."),
                LessonSection(heading: "Choose the right storage", body: "Use AppStorage/UserDefaults for small preferences such as an appearance setting. Use a structured database for records such as quiz attempts. Transient answer selection belongs in memory until the completed attempt is saved. Do not put secrets or large datasets in preferences.")]),
        Lesson(id: "vision", subjectID: "ios", title: "Vision OCR & App Quality", minutes: 6,
            introduction: "Recognise text from images and verify your app's behaviour.", sections: [
                LessonSection(heading: "Text recognition with Vision", body: "Apple Vision provides VNRecognizeTextRequest for recognising text in an image. A VNImageRequestHandler performs the request. Its results contain recognised observations; topCandidates(1) retrieves a likely text candidate for each observation. Recognition can make mistakes."),
                LessonSection(heading: "Keep expensive work off the UI thread", body: "Image decoding and recognition can take time. Run expensive processing away from the main thread, show a loading state and return results to the UI safely. Correctly interpret image orientation. Test a clean image, a rotated photo and an image with no text."),
                LessonSection(heading: "Test the right behaviour", body: "Unit tests check isolated rules such as scoring and duplicate-answer protection. UI tests exercise navigation and controls. User testing reveals usability issues. Accessibility checks should include VoiceOver, larger text, contrast and Reduce Motion. Only report tests that have actually run.")])
    ]
    static func lessons(for subject: Subject) -> [Lesson] { lessons.filter { $0.subjectID == subject.id } }
    static func subject(for lesson: Lesson) -> Subject { subjects.first { $0.id == lesson.subjectID } ?? subjects[0] }
    static func questions(for lesson: Lesson) -> [Question] { questions.filter { $0.lessonID == lesson.id } }
    static let questions: [Question] = [
        q("v1", "values", "Which keyword declares a constant?", ["var", "let", "func", "class"], 1, "let prevents reassignment of the declared value."),
        q("v2", "values", "Which type is suitable for a whole-number attempt count?", ["String", "Bool", "Int", "Character"], 2, "Int represents whole numbers such as 0, 1 and 2."),
        q("v3", "values", "What does String? mean?", ["A required String", "A String or nil", "An array of Strings", "A constant String"], 1, "The ? declares an optional that can represent a missing value with nil."),
        q("v4", "values", "Which operator provides a fallback for nil?", ["&&", "==", "??", "+="], 2, "The nil-coalescing operator ?? supplies a fallback value."),
        q("v5", "values", "What happens when a nil optional is force-unwrapped?", ["It becomes zero", "It becomes an empty String", "It is ignored", "The program traps at runtime"], 3, "Using ! on nil causes a runtime trap. Unwrap safely instead."),
        q("f1", "functions", "Which keyword defines a Swift function?", ["func", "method", "function", "define"], 0, "func introduces a named Swift function."),
        q("f2", "functions", "Which collection contains unique elements?", ["Array", "Set", "Tuple", "String"], 1, "A Set does not keep duplicate elements."),
        q("f3", "functions", "Which operation selects elements matching a condition?", ["map", "reduce", "filter", "append"], 2, "filter returns elements for which its predicate is true."),
        q("f4", "functions", "Assigning a struct to another variable normally gives…", ["A shared class instance", "An independent value", "A network reference", "An optional"], 1, "Structs have value semantics: changing the copy does not change the original value."),
        q("f5", "functions", "A struct method changes a stored property. Which keyword is required?", ["static", "override", "mutating", "final"], 2, "mutating allows a struct method to change the instance's stored properties."),
        q("u1", "views", "A typical SwiftUI screen is a struct conforming to…", ["Model", "View", "SceneDelegate", "ObservableObject"], 1, "SwiftUI views conform to View and supply a body."),
        q("u2", "views", "What is body in a typical SwiftUI View?", ["A stored String", "An initializer", "A computed property", "A database table"], 2, "body computes a description of the view hierarchy."),
        q("u3", "views", "Which stack layers children over each other?", ["VStack", "HStack", "ZStack", "NavigationStack"], 2, "ZStack overlaps its children along the depth axis."),
        q("u4", "views", "Which is suitable for reusable view styling?", ["ViewModifier", "URLSession", "ModelContext", "DateFormatter"], 0, "ViewModifier encapsulates reusable view modifications."),
        q("u5", "views", "Which font choice best supports Dynamic Type?", ["A fixed-size screenshot", "A tiny fixed pixel font", ".font(.body)", "Image-only text"], 2, "Semantic text styles adapt to the user's preferred text size."),
        q("s1", "state", "Which wrapper commonly owns local selected-answer state?", ["@Query", "@State", "@Model", "@main"], 1, "@State owns transient local view state."),
        q("s2", "state", "What does @Binding provide?", ["A new database", "An immutable copy", "Read/write access to state owned elsewhere", "A network request"], 2, "A binding connects a child control to an existing source of truth."),
        q("s3", "state", "Which view manages stack-based navigation?", ["NavigationStack", "VStack", "TextEditor", "ProgressView"], 0, "NavigationStack manages a hierarchy of navigation destinations."),
        q("s4", "state", "Which control normally pushes a destination?", ["Toggle", "NavigationLink", "Divider", "Spacer"], 1, "NavigationLink initiates navigation to a destination."),
        q("s5", "state", "Will @State alone reliably keep quiz history after app termination?", ["Yes, always", "Only in Dark Mode", "No, use durable persistence", "Only on iPad"], 2, "@State is transient. Store completed attempts with a persistence mechanism."),
        q("p1", "persistence", "Which macro defines a SwiftData model?", ["@State", "@Binding", "@Model", "@ViewBuilder"], 2, "@Model enables SwiftData to manage a model class."),
        q("p2", "persistence", "Which type performs inserts and saves?", ["ModelContext", "NavigationPath", "PhotosPicker", "Color"], 0, "ModelContext manages model operations within a container."),
        q("p3", "persistence", "What is a suitable use of AppStorage?", ["A large video library", "An appearance preference", "An entire image dataset", "A password store"], 1, "AppStorage is appropriate for small preferences."),
        q("p4", "persistence", "What should happen if saving an attempt fails?", ["Claim it was saved", "Hide the failure", "Show an error and allow retry", "Delete all history"], 2, "Users need accurate feedback and a safe way to retry."),
        q("p5", "persistence", "Which check verifies persistence beyond one container's lifetime?", ["Change the app icon", "Reopen the store and fetch the record", "Only inspect a label", "Toggle Dark Mode"], 1, "Reopening a disk store checks that saved data can be retrieved later."),
        q("o1", "vision", "Which Vision request recognises text?", ["MKLocalSearch", "VNRecognizeTextRequest", "ModelConfiguration", "NavigationLink"], 1, "VNRecognizeTextRequest is Vision's image text-recognition request."),
        q("o2", "vision", "What performs a Vision request on an image?", ["VNImageRequestHandler", "UserDefaults", "HStack", "AppStorage"], 0, "VNImageRequestHandler executes image-based Vision requests."),
        q("o3", "vision", "Where should expensive OCR processing run?", ["Inside every body evaluation", "Away from the main UI thread", "Only inside a button label", "In the asset catalogue"], 1, "Background processing keeps the interface responsive."),
        q("o4", "vision", "Is recognised OCR text guaranteed correct?", ["Yes", "Only if it is long", "No; review the output", "Only on a simulator"], 2, "Recognition can make mistakes, so the learner should review the text."),
        q("o5", "vision", "Which test best checks quiz score calculation in isolation?", ["An icon screenshot", "A unit test", "A store listing", "A pitch slide"], 1, "A unit test exercises scoring rules with controlled inputs.")
    ]
    private static func q(_ id: String, _ lesson: String, _ text: String, _ options: [String], _ correct: Int, _ why: String) -> Question {
        Question(id: id, lessonID: lesson, questionText: text, options: options, correctAnswerIndex: correct, explanation: why)
    }
}
