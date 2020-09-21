import mongoose from 'mongoose';

const Schema = mongoose.Schema;

export const ArticleInfoSchema = new Schema({
  journal: {
    type: String
  },
  pubID: {
    type: String
  },
  file: {
    type: String
  },
  section: {
    type: String
  },
  series: {
    type: String
  },
  title: {
    type: String
  },
  firstAuthor: {
    type: String
  },
  graphics: {
    type: String
  },
  dataSupplements: {
    type: String
  },
  username: {
    type: String
  },
  report: {
    type: String
  },
  status: {
    type: String
  },
  info: {
    type: String
  },
  pubHWX: {
    type: String
  },
  embargoDate: {
    type: String
  },
  embargoTime: {
    type: String
  },
  vol: {
    type: String
  },
  articleLink: {
    type: String
  },
  hwBatch: {
    type: String
  },
  created_date: {
    type: Date,
    default: Date.now
  }
});