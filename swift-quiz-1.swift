import UIKit //import Foundation тк uikit избыточен, нет работы с ui

protocol ReaderDelegate: class { //: AnyObject чтобы могли использовать только классы
    func didReadData(data: Data)
}

class Reader { //можно указать final class если не будет наследовавния от него
    var file: String! //String? используем опционал чтобы избежать крашей
    var output: ReaderDelegate? //weak var чтобы избежать retain cycle
    var readCompleteBlock: (() -> Void)?
    
    func read() {
//        guard let file = file else {
//            return
//        } распаковываем file
        let fileUrl = URL(fileURLWithPath: file)
        if let data = try? Data(contentsOf: fileUrl) {
            self.output?.didReadData(data: data)
            self.readCompleteBlock?();
        } //if let чтобы не использрвать принудительную распаковку, можно написать print() для отслеживания ошибок
    }
}

class orderReader: ReaderDelegate { //OrderReader тк классы всегда объявляются с большой буквы, можно указать final class если не будет наследовавния от него
    public var reader: Reader //если исходить только из данного конекста public нужно заменить на private
    init(_ file: URL) {
        self.reader = Reader()
        self.reader.file = file.absoluteString.replacingOccurrences(of: "file://", with: "") //self.reader.file = file.path можно использовать обращение к адресу напрямую
        self.reader.output = self
        self.reader.readCompleteBlock = {
            self.didComplete()
        }
    }
    
    func Read() {
        self.reader.read() //не нужен self
    }
    
    func didComplete() {
        print("end of file")
    }
    
    func didReadData(data: Data) {
        print("\(data)")
    }
}

let filePath = Bundle.main.path(forResource: "myOrders.csv", ofType: nil)
let orderReader = orderReader(URL(fileURLWithPath: filePath!))
orderReader.Read()
//if let filePath = Bundle.main.path(forResource: "myOrders.csv", ofType: nil) {
//    let orderReader = OrderReader(URL(fileURLWithPath: filePath))
//    orderReader.Read()
//} проверяем адрес перед вызовом
