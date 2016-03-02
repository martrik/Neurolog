import React, { 
  StyleSheet,
  Picker,
  View, 
  Text
} from 'react-native';
   
export default class NewRecordScreen extends React.Component {
  constructor(props, context){
    super(props, context);
    this.state = {
      lang: 'java',
      modelIndex: 1,
    }
  }

  render () {
    return (
      <View style={styles.container}>
        <Text>
        Hello</Text>
        <Picker selectedValue={this.state.lang} onValueChange={(lang) => this.setState({lang, modelIndex: 0})}>
          <Picker.Item label="Java" value="java" />
          <Picker.Item label="JavaScript" value="js" />
        </Picker>
      </View>
    ); 
  }
}

var styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 64
  }, 
  title: {
    height: 40 
  },
  body: {
    flex: 1
  } 
});