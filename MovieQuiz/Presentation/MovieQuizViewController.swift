import UIKit

final class MovieQuizViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties

    // переменная с индексом текущего вопроса, начальное значение 0 (так как индекс в массиве начинается с 0)
    private var currentQuestionIndex = 0
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    // переменная определяет доступность кнопки для взаимодействия с пользователем
    private var isAnswerButtonsEnabled = true
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

        setupQuestionFactory()
    }

    // MARK: - Actions

    // метод вызывается, когда пользователь нажимает на кнопку "Да"
    @IBAction private func yesButtonTapped(_ sender: UIButton) {
        if isAnswerButtonsEnabled {
            checkAnswer(true)
        }
    }

    // метод вызывается, когда пользователь нажимает на кнопку "Нет"
    @IBAction private func noButtonTapped(_ sender: UIButton) {
        if isAnswerButtonsEnabled {
            checkAnswer(false)
        }
    }

    // MARK: - Setup

    private func setupQuestionFactory() {
        questionFactory = QuestionFactory(
            moviesLoader: MoviesLoader(),
            delegate: self
        )

        showLoadingIndicator()
        questionFactory?.loadData()
    }

    private func setupImageView() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
    }

    // MARK: - Mapping

    // метод конвертации вопроса во вьюмодель
    private func convert(model: QuizQuestion) -> QuizStepViewModel {

        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
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
    private func show(quiz step: QuizStepViewModel) {
        setupImageView()
        imageView.image = step.image
        imageView.layer.borderColor = UIColor.clear.cgColor
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

            self.restartGame()
        }

        alertPresenter.show(in: self, model: alertModel)
    }

    // MARK: - Quiz Flow

    // приватный метод, который меняет цвет рамки
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }

        setupImageView()
        imageView.layer.borderColor =
            isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        isAnswerButtonsEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
            self.isAnswerButtonsEnabled = true
        }
    }

    private func makeQuizResultText() -> String {
        "Ваш результат: \(correctAnswers)/\(questionsAmount)\nКоличество сыгранных квизов: \(statisticService.gamesCount)\nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
    }

    // приватный метод, который содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(
                correct: correctAnswers,
                total: questionsAmount
            )

            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: makeQuizResultText(),
                buttonText: "Сыграть еще раз"
            )

            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }

    // перезапуск игры
    private func restartGame() {
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
        self.questionFactory?.requestNextQuestion()
    }

    // показывает индикатор загрузки
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    // скрывает индикатор загрузки
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }

    // Показывает ошибку сети в виде алерта
    private func showNetworkError(message: String) {
        hideLoadingIndicator()

        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            guard let self else { return }

            self.restartGame()
        }
        alertPresenter.show(in: self, model: model)
    }
}

// MARK: - QuestionFactoryDelegate

extension MovieQuizViewController: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription)
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }

        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}
