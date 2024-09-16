import UIKit //import Foundation тк uikit избыточен, нет работы с ui

protocol ReaderDelegate: class { //: AnyObject чтобы могли использовать только классы
    func didReadData(data: Data)
}

class Reader { //можно указать final class если не будет наследовавния от него
    var fileURL: URL! //String? используем опционал чтобы избежать крашей, можно сразу указать тип данных URL
    var output: ReaderDelegate? //weak var чтобы избежать retain cycle
    var readCompleteBlock: (() -> Void)?
    
    func read() {
        //        guard let file = file else {
        //            return
        //        } распаковываем file
        DispatchQueue.global(qos: .background).async {
            let data = try Data(contentsOf: fileUrl)
            self.output?.didReadData(data: data)
            self.readCompleteBlock?()
        }  //if let чтобы не использрвать принудительную распаковку, можно написать print() для отслеживания ошибок, запрос на чтение файла можно выполнять не в главном потоку, приоритет потока qos выбрать в зависимости от нужд. Еще можно добавить проверку ошибок через do {} catch {} и проверку на существование файла
    }
}

class orderReader: ReaderDelegate { //OrderReader тк классы всегда объявляются с большой буквы, можно указать final class если не будет наследовавния от него
    public var reader: Reader //если исходить только из данного конекста public нужно заменить на private
    init(_ file: URL) {
        self.reader = Reader()
        self.reader.file = file.absoluteString.replacingOccurrences(of: "file://", with: "") //self.reader.file = file.path можно использовать обращение к адресу напрямую
        self.reader.output = self
        self.reader.readCompleteBlock = { //[weak self] чтобы избежать захвата сильный сслыки в замыкании
            self.didComplete()
        }
    }
    
    func Read() {
        self.reader.read() //не нужен self
    }
    
    func didComplete() {
        print("end of file")
        //можно преобразовать данные в стоку if let content = String(data: data, encoding: .utf8)
        //{
        //        print(content)
        //    } else {
        //        print("Unable to convert data to string")
        //    }
    }
    
    func didReadData(data: Data) {
        print("\(data)")
        // и тут тоже
    }
}

let filePath = Bundle.main.path(forResource: "myOrders.csv", ofType: nil)
let orderReader = orderReader(URL(fileURLWithPath: filePath!))
orderReader.Read()
//if let filePath = Bundle.main.path(forResource: "myOrders.csv", ofType: nil) {
//    let orderReader = OrderReader(URL(fileURLWithPath: filePath))
//    orderReader.Read()
//} проверяем адрес перед вызовом


