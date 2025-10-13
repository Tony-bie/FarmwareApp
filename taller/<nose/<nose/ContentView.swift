import SwiftUI

struct ContentView: View {
    @State private var nombre: String = ""
    @State private var saludo: String = ""
    @State private var contador: Int = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Lemme greet you")
                .font(.title)
                .foregroundColor(.black)
            TextField("Enter your name", text: $nombre)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Greet") {
                saludo = "Heyy, \(nombre)! "
                
            }
            .buttonStyle(.borderedProminent)
            
            Button("Más"){
                contador = contador + 100000000
            }
            
            Text("Contador: \(contador)")
            
            Button("Menos"){
                contador = contador - 100000000
            }
            
            Image("hola")
            
            
            Text (saludo)
                .font(.headline)
                .foregroundColor(.green)
        }
        
        .padding()
            
        }
    }

#Preview {
    ContentView()
}
