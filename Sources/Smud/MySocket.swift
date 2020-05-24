
import Foundation
import Socket
import Dispatch

class EchoServer {

	static let quitCommand : String = "QUIT"
	static let shutdownCommand : String = "SHUTDOWN"
	static let bufferSize = 4096


	let port:Int
	var listenSocket : Socket? = nil
	var continueRunningValue = true
	var connectedSockets = [Int32:Socket]()
	let socketLockQueue = DispatchQueue(label:"smud.socketLockQueue")
	var continueRunning:Bool {
		set(newValue){
			socketLockQueue.sync{
				self.continueRunningValue = newValue
			}
		}
		get {
			return socketLockQueue.sync{
				self.continueRunningValue
			}
		}
	}

	init(port:Int){
		self.port = port
	}

	deinit{
		//Closeallopensockets...
		for socket in connectedSockets.values{
			socket.close()
		}
		self.listenSocket?.close()
	}

	func run(){

		let queue = DispatchQueue.global(qos:.userInteractive)

		queue.async{[unowned self] in

			do {
				//CreateanIPV6socket...
				try self.listenSocket = Socket.create()

				guard let socket = self.listenSocket else {

					print("Unable to unwrap socket...")
					return
				}

				try socket.listen(on:self.port)

				print("Listening on port:\(socket.listeningPort)")

				repeat {
					let newSocket = try socket.acceptClientConnection()

					print("Accepted connection from:\(newSocket.remoteHostname) on port \(newSocket.remotePort)")
					print("Socket Signature:\(String(describing:newSocket.signature?.description))")

					self.addNewConnection(socket:newSocket)

				} while 1 == 1 //self.continueRunning

			}
			catch let error{
				guard let socketError=error as? Socket.Error else{
					print("Unexpected error...")
					return
				}

				if self.continueRunning {

					print("Error reported:\n\(socketError.description)")

				}
			}
		}
		dispatchMain()
	}

	func addNewConnection(socket:Socket) {

		//Addthenewsockettothelistofconnectedsockets...
		socketLockQueue.sync { [unowned self, socket] in
			self.connectedSockets[socket.socketfd] = socket
			}

			let queue = DispatchQueue.global(qos:.userInteractive)

			queue.async { [unowned self] in
			let SmudPlugin = ConsolePlugin(smud: smud, socket: socket)
			SmudPlugin.willEnterGameLoop()
		}
	}

	func CloseSocket(socket: Socket){
	  print("Socket:\(socket.remoteHostname):\(socket.remotePort)closed...")
	  socket.close()

	 self.socketLockQueue.sync { [unowned self,socket] in
	  	self.connectedSockets[socket.socketfd] = nil
	 }
	}

	func shutdownServer(){
		print("\nShutdown in progress...")

		self.continueRunning=false

		//Closeallopensockets...
		for socket in connectedSockets.values{

			self.socketLockQueue.sync{[unowned self,socket] in
				self.connectedSockets[socket.socketfd] = nil
				socket.close()
			}
		}

		DispatchQueue.main.sync{
			exit(0)
		}
	}
}
