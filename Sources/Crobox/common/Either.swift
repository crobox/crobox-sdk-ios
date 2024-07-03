import Foundation

enum Either<E, T> {
  case success(T)
  case error(E)
}
