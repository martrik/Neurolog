/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */
'use strict';
import React, {
  AppRegistry,
  Navigator,
  StyleSheet,
  View,
  Text,
  Component
} from 'react-native';

import SimpleButton from './app/components/SimpleButton';
import NewRecordScreen from './app/components/NewRecordScreen';
import HomeScreen from './app/components/HomeScreen';

var NavigationBarRouteMapper = {
    RightButton: function(route, navigator, index, navState) {
		switch (route.name) {
        case 'home':
            return (
            	<SimpleButton
	               onPress={() => {
	                 navigator.push({
	                   name: 'newRecord'
	                   }); }}
	               	customText='Create New Record'
             	/>
			); 
        default:
            return(null);
       } 
	},
    LeftButton: function(route, navigator, index, navState) {
		switch (route.name) {
        case 'newRecord':
           return (
             <SimpleButton
               onPress={() => navigator.pop()}
               customText='Back'
              />
		); 
        default:
           return null;
       }
	},
    Title: function(route, navigator, index, navState) {
    	switch (route.name) {
    	case 'home':
           return (
             <Text>React Notes</Text>
           );
        case 'createNote':
           	return (
            	<Text>Create Note</Text>
           	);
		} 	
	}
};

class Neurolog extends Component {
	renderScene (route, navigator) {
		switch (route.name) {
		case 'home':
			return (<HomeScreen/>);

		case 'newRecord':
			return (<NewRecordScreen/>);
		}
	}
	render() {
		return (
			<Navigator
			    initialRoute={{name: 'home'}}
			    renderScene={this.renderScene}
			    navigationBar={
			    	<Navigator.NavigationBar
			    		routeMapper={NavigationBarRouteMapper}
			    	/>
			    }
			/>
		);
	}
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});

AppRegistry.registerComponent('Neurolog', () => Neurolog);