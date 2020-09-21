import {
  addNewArticle,
  getArticleInfo,
  getArticleByID
  // getContactWithID,
  // updateContact,
  // deleteContact
} from '../controllers/artInfoController'

const routes = (app) => {
  app.route('/articleInfo')
    .get((req, res, next) => {
      // middleware
      console.log(`Request from: ${req.originalUrl}`)
      console.log(`Request type: ${req.method}`)
      next();
    }, getArticleInfo)

    // Post endpoint
    .post(addNewArticle);

  app.route('/articleInfo/:articleID')
  .get(getArticleByID)

  //app.route('/articleInfo/:articleByJournal')
    // get a specific contact
    //.get(getArticleByJournal)
    // updating a specific contact
    //.put(updateContact)
    // deleting a specific contact
    //.delete(deleteContact)

} 

export default routes;