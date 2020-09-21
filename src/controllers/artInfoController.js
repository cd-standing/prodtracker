import mongoose from 'mongoose';
import { ArticleInfoSchema } from '../models/artInfoModel';

const ArticleInfo = mongoose.model('ArticleInfo', ArticleInfoSchema);

export const addNewArticle = (req, res) => {
  let newArticleInfo = new ArticleInfo(req.body);

  newArticleInfo.save((err, articleInfo) => {
    if (err) {
      res.send(err);
    }
    res.json(articleInfo);
  });
}

export const getArticleInfo = (req, res) => {
  ArticleInfo.find({}, (err, articleInfo) => {
    if (err) {
      res.send(err);
    }
    res.json(articleInfo);
  });
}

export const getArticleByID = (req, res) => {
  ArticleInfo.findById(req.params.articleID, (err, articleInfo) => {
    if (err) {
      res.send(err);
    }
    res.json(articleInfo);
  });
}



/* export const getContactWithID = (req, res) => {
  Contact.findById(req.params.contactID, (err, contact) => {
    if (err) {
      res.send(err);
    }
    res.json(contact);
  });
}

export const updateContact = (req, res) => {
  Contact.findOneAndUpdate({
    _id: req.params.contactID
  },
    req.body,
    { new: true, useFindAndModify: false },
    (err, contact) => {
      if (err) {
        res.send(err);
      }
      res.json(contact);
    });
}

export const deleteContact = (req, res) => {
  Contact.remove({ _id: req.params.contactID }, req.body, (err, contact) => {
      if (err) {
        res.send(err);
      }
      res.json( {message: 'Successfully deleted contact!'}) ;
    });
} */