import React from 'react';
import { Text, Image, Document, StyleSheet, Page } from '@react-pdf/renderer';
import PADA_LOGO from './assets/DegreeImgs/Pada_LOGO.png';
import SignatureIMG from './assets/DegreeImgs/aSignature.png';

const styles = StyleSheet.create({
  body: {
    paddingTop: 35,
    paddingBottom: 65,
    paddingHorizontal: 35,
  },
  title: {
    fontSize: 24,
    textAlign: 'center',
  },
  text: {
    margin: 12,
    fontSize: 14,
    textAlign: 'justify',
    fontFamily: 'Times-Roman',
  },
  image1: {
    marginVertical: 15,
    marginHorizontal: 100,
  },
  image2: {
    marginVertical: 15,
    marginHorizontal: 180,
    width: 170,
    height: 170,
  },
  header: {
    fontSize: 12,
    marginBottom: 20,
    textAlign: 'center',
    color: 'grey',
  },
  pageNumber: {
    position: 'absolute',
    fontSize: 12,
    bottom: 30,
    left: 0,
    right: 0,
    textAlign: 'center',
    color: 'grey',
  },
});

const PDFfile = () => {
  return (
    <Document>
      <Page style={styles.body}>
        <Text style={styles.header} fixed></Text>
        <Image style={styles.image1} src={PADA_LOGO} />
        <Text style={styles.text}>
          Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla in
          velit at mauris posuere cursus vitae molestie eros. Integer
          ullamcorper dolor gravida est eleifend placerat. Mauris vulputate
          rutrum nisi non ornare. Aliquam sit amet ipsum ex. Vestibulum quis
          risus a leo aliquam tempor quis a velit. Praesent consectetur
          sollicitudin dolor, vel finibus ante semper ut. Ut arcu magna, dictum
          sit amet orci at, pretium faucibus est. Aliquam ultrices elit vitae
          metus semper, in venenatis tortor pellentesque. Donec mattis iaculis
          arcu nec viverra. Quisque nec imperdiet lectus, at laoreet ante. Nunc
          eget imperdiet sapien. Aliquam vulputate nunc metus, quis mattis purus
          pulvinar et. Pellentesque at lorem lobortis, sollicitudin sapien
          mattis
        </Text>
        <Image style={styles.image2} src={SignatureIMG} />
      </Page>
    </Document>
  );
};

export default PDFfile;
