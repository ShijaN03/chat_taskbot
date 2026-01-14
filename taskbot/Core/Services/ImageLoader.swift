//
//  ImageLoader.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit

final class ImageLoader {
    
    static let shared = ImageLoader()
    
    private let cache = NSCache<NSURL, UIImage>()
    private let session: URLSession
    
    private init() {
        session = URLSession(configuration: .default)
    }
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask? {
        if let cached = cache.object(forKey: url as NSURL) {
            completion(cached)
            return nil
        }
        
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            guard
                error == nil,
                let data = data,
                let image = UIImage(data: data)
            else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            self?.cache.setObject(image, forKey: url as NSURL)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
        
        task.resume()
        return task
    }
}


