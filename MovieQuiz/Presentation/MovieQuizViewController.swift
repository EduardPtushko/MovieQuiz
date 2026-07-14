import UIKit

final class MovieQuizViewController: UIViewController,
    MovieQuizViewControllerProtocol
{

    // MARK: - IBOutlets

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties

    private var alertPresenter = AlertPresenter()
    private var presenter: MovieQuizPresenter!
    var isAnswerButtonsEnabled = true

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = MovieQuizPresenter(viewController: self)
        imageView.layer.cornerRadius = 20
    }

    // MARK: - Actions

    @IBAction private func yesButtonTapped(_ sender: UIButton) {
        if isAnswerButtonsEnabled {
            presenter.yesButtonTapped()
        }
    }

    @IBAction private func noButtonTapped(_ sender: UIButton) {
        if isAnswerButtonsEnabled {
            presenter.noButtonTapped()
        }
    }

    // MARK: - Presentation

    func show(quiz step: QuizStepViewModel) {
        imageView.image = UIImage(data: step.image) ?? UIImage()
        imageView.layer.borderColor = UIColor.clear.cgColor
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self else { return }

            presenter.restartGame()
        }

        alertPresenter.show(in: self, model: alertModel)
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8

        imageView.layer.borderColor =
            isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }

    func showNetworkError(message: String) {
        hideLoadingIndicator()

        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            guard let self else { return }

            presenter.restartGame()
        }
        alertPresenter.show(in: self, model: model)
    }
}
