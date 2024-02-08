//
//  CustomAnnotation.swift
//  Shuttle Tracker
//
//  Created by Gabriel Jacoby-Cooper on 9/21/20.
//

import MapKit

protocol CustomAnnotation: MKAnnotation {
	
    #if os(iOS) || os(macOS)
	var annotationView: MKAnnotationView { get }
    #endif
}
