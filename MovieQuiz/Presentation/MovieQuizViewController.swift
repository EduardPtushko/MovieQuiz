import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    // MARK: - IBOutlets

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!

    // MARK: - Properties

    // переменная с индексом текущего вопроса, начальное значение 0 (так как индекс в массиве начинается с 0)
    private var currentQuestionIndex = 0
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    // переменная определяет доступность кнопки для взаимодействия с пользователем
    private var isEnabled = true
    // общее количество вопросов для квиза
    private let questionsAmount: Int = 10
    // фабрика вопросов
    private var questionFactory: QuestionFactoryProtocol?
    // вопрос, который видит пользователь
    private var currentQuestion: QuizQuestion?
    // компонент для отображения системных алертов и уведомлений пользователю
    private var alertPresenter = AlertPresenter()
    // сервис для сбора, подсчета и сохранения статистики игровых сессий
    private var statisticService: StatisticServiceProtocol = StatisticService()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory

        self.questionFactory?.requestNextQuestion()
    }

    // MARK: - Actions

    // метод вызывается, когда пользователь нажимает на кнопку "Да"
    @IBAction private func yesButtonTapped(_ sender: UIButton) {
        if isEnabled {
            checkAnswer(true)
        }
    }

    // метод вызывается, когда пользователь нажимает на кнопку "Нет"
    @IBAction private func noButtonTapped(_ sender: UIButton) {
        if isEnabled {
            checkAnswer(false)
        }
    }

    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }

        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }

    // MARK: - Mapping

    // приватный метод конвертации, который принимает моковый вопрос
    // и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    // MARK: - Checking Answer

    private func checkAnswer(_ givenAnswer: Bool) {
        guard let currentQuestion else { return }

        showAnswerResult(
            isCorrect: currentQuestion.correctAnswer == givenAnswer
        )
    }

    // MARK: - Presentation

    // приватный метод вывода на экран вопроса,
    // который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = 16
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    // приватный метод вывода на экран алерта с результатами квиза
    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self else { return }

            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }

        alertPresenter.show(in: self, model: alertModel)
    }

    // MARK: - Quiz Flow

    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor =
            isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
        isEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
            self.isEnabled = true
        }
    }

    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(
                correct: correctAnswers,
                total: questionsAmount
            )

            let text =
                "Ваш результат: \(correctAnswers)/\(questionsAmount)\nКоличество сыгранных квизов: \(statisticService.gamesCount)\nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз"
            )

            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
}
