#import "@preview/oxifmt:0.2.0": strfmt
#import "./global.typ" : *
#import "./auxiliary.typ": *
#import "./g-question.typ": *
#import "./g-solution.typ": *
#import "./g-clarification.typ": *

/// Template for creating an exam.
/// 
///  - author: Infomation of author of exam.
///  - name (string, content): Name of author of exam.
///  - email (string): E-mail of author of exam.
///  - watermark (string): Watermark with information about the author of the document.
///  - school: Information of school.
///  - name (string, content): Name of the school or institution generating the exam.
///  - logo (none, content, bytes): Logo of the school or institution generating the exam.
///  - exam-info: Information of exam.
///  - academic-period (none, content, str): Academic period.
///  - academic-level (none, content, str): Academic level.
///  - academic-subject (none, content, str): Academic subname.
///  - number (none, content, str): Number of exam.
///  - content (none, content, str): Content of exam.
///  - model (none, content, str): Model of exam.
///  - date (sting): Date of generate document.
///  - keywords (string): Keywords of document.
///  - language (en, es, de, fr, pt, it): Language of document. English, Spanish, German, French, Portuguese and Italian are defined.
///  - clarifications (string, content, array): Clarifications of exam. It will appear in a box on the first page.
///  - question-text-parameters: Parameter of text in question and subquestion. For example, it allows us to change the text size of the questions.
///  - show-student-data (none, true, false, "first-page", "odd-pages"): Show a box for the student to enter their details. It can appear on the first page or on all odd-numbered pages.
///  - show-grade-table: (bool): Show the grade table.
///  - decimal-separator: (".", ","): Indicate the decimal separation character.
///  - question-point-position: (none, left, right): Position of question points.
///  - show-solution: (true, false): Show the solutions.
#let g-exam(
  author: (
    name: "",
    email: none,
    watermark: none
  ),
  school: (
    name: none,
    logo: none,
  ),
  exam-info: (
    academic-period: none,
    academic-level: none,
    academic-subject: none,
    number: none,
    content: none,
    model: none
  ),
  language: "en",
  localization: (
    grade-table-queston: none,
    grade-table-total: none,
    grade-table-points: none,
    grade-table-calification: none,
    point: none,
    points: none,
    page: none,
    page-counter-display: none,
    family-name: none,
    given-name: none,
    group: none,
    date: none
  ),
  date: none,
  keywords: none,
  clarifications: none,
  question-text-parameters: none,
  show-student-data: "first-page",
  show-grade-table: true,
  decimal-separator: ".",
  question-point-position: left,
  show-solution: true,
  body,
) = {
  
  assert(show-student-data in (none, true, false, "first-page", "odd-pages"),
      message: "Invalid show studen data")

  assert(question-point-position in (none, left, right),
      message: "Invalid question point position")

  assert(decimal-separator in (".", ","),
      message: "Invalid decimal separator")

  assert(show-solution in (true, false),
      message: "Invalid show solution value")

  set document(
    title: __document-name(exam-info: exam-info).trim(" "),
    author: author.name
  )

  let margin-right = 2.5cm
  if (question-point-position == right) {
    margin-right = 3cm
  }

  set page(
    paper: "a4", 
    margin: (top: 5cm, right:margin-right),
    numbering: "1 / 1",
    number-align: right,
    header-ascent: 20%,
    header:locate(loc => {
        let __page-number = counter(page).at(loc).first() 
        __show-header(page-number: __page-number, school: school, exam-info: exam-info, show-student-data: show-student-data)
      }
    ),

    footer: locate(loc => {
        line(length: 100%, stroke: 1pt + gray) 
        align(right)[
            #__g-localization.final(loc).page
            #counter(page).display(__g-localization.final(loc).page-counter-display, both: true,
            )
        ]
        // grid(
        //   columns: (1fr, 1fr, 1fr),
        //   align(left)[#school.name],
        //   align(center)[#exam-info.academic-period],
        //   align(right)[
        //     Página 
        //     #counter(page).display({
        //       "1 de 1"},
        //       both: true,
        //     )
        //   ]
        // )

        __show-watermark(author: author, school: school, exam-info: exam-info, question-point-position:question-point-position)
      }
    )
  )  

  set par(justify: true) 
  set text(font: "New Computer Modern")
  
  __read-localization(language: language, localization: localization)
  __g-question-point-position-state.update(u => question-point-position)
  __g-question-text-parameters-state.update(question-text-parameters)

  set text(lang:language)

  if show-grade-table == true {
    __g-grade-table-header(
      decimal-separator: decimal-separator,
    )
    v(10pt)
  }

  __g-show-solution.update(show-solution)

  set par(justify: true) 

  if clarifications != none {
    __g-show_clarifications(clarifications: clarifications)
  }

  show regex("=\?"): it => {
      let (sugar) = it.text.split()
      g-question[]
    }

  show regex("=\? (.+)"): it => {
      let (sugar, ..rest) = it.text.split()
      g-question[#rest.join(" ")]
    }

  show regex("=\? [[:digit:]] (.+)"): it => {
      let (sugar, point, ..rest) = it.text.split()
      g-question(point:float(point))[#rest.join(" ")]
    }

  show regex("==\?"): it => {
      let (sugar) = it.text.split()
      g-subquestion[]
    }

  show regex("==\? (.+)"): it => {
      let (sugar, ..rest) = it.text.split()
      g-subquestion[#rest.join(" ")]
    }

  show regex("==\? [[:digit:]] (.+)"): it => {
      let (sugar, point, ..rest) = it.text.split()
      g-subquestion(point:float(point))[#rest.join(" ")]
    }

  show regex("=! (.+)"): it => {
      let (sugar, ..rest) = it.text.split()
      g-solution[#rest.join(" ")]
    }

  show regex("=% (.+)"): it => {
      let (sugar, ..rest) = it.text.split()
      g-clarification[#rest.join(" ")]
    }

  body
  
  [#hide[]<end-g-question-localization>]
  [#hide[]<end-g-exam>]
}
