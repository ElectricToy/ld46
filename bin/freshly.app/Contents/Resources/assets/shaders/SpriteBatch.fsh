//
//  SpriteBatch.fsh
//  FreshScene2D
//
//  Created by Jeff Wofford on 5/28/10.
//  Copyright jeffwofford.com 2010. All rights reserved.
//
uniform sampler2D diffuseTexture;

varying highp vec2 fragment_texCoord;
varying highp vec4 fragment_color;
varying highp vec4 fragment_additiveColor;

void main()
{
	vec4 color = fragment_color * texture2D( diffuseTexture, fragment_texCoord );
	gl_FragColor = color + color.a * vec4( fragment_additiveColor.rgb, 0.0 );
}
