//
//  CustomAnnotation.swift
//  Rensselaer Shuttle
//
//  Created by Gabriel Jacoby-Cooper on 9/21/20.
//

import MapKit

protocol CustomAnnotation: MKAnnotation {
	
	var annotationView: MKAnnotationView { get }
	
}
