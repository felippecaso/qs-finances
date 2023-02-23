def model(dbt, session):

    import re
    from textblob.classifiers import NaiveBayesClassifier
    
    import nltk
    import pandas as pd


    try:
        nltk.data.find('tokenizers/punkt')
    except LookupError:
        nltk.download('punkt')

    def _strip_numbers(s):
        """Strip numbers from the given string"""
        return re.sub("[^A-Z ]", "", str(s))

    def _split_by_multiple_delims(string, delims):
        """Split the given string by the list of delimiters given"""
        regexp = "|".join(delims)
        return re.split(regexp, string)

    def _get_training(df):
        """Get training data for the classifier, consisting of tuples of
        (text, category)"""
        train = []
        subset = df.loc[(df['category']!='') & (df['category_source']!='guess')].reset_index(drop=True)
        for i in subset.index:
            row = subset.iloc[i]
            new_desc = _strip_numbers(row['description'])
            train.append( (new_desc, row['category']) )
        return train

    def _extractor(doc):
        """Extract tokens from a given string"""
        tokens = _split_by_multiple_delims(doc, [' ', '/'])
        features = {}
        for token in tokens:
            if token == "":
                continue
            features[token] = True
        return features

    df_transactions = dbt.ref('int_transactions_unioned').df()
    df_transactions['category'] = ''
    df_transactions['category_source'] = ''

    df_train = df_transactions.loc[((df_transactions['category'].notna()) & (df_transactions['category_source']!='guess'))].reset_index(drop=True)
    classifier = NaiveBayesClassifier(_get_training(df_train), _extractor)

    df_classify = df_transactions.loc[((df_transactions['category'].isna()) | (df_transactions['category_source']=='guess'))].reset_index(drop=True)

    for index, row in df_classify.iterrows():

        stripped_text = _strip_numbers(row['description'])
        guessed_category = classifier.classify(stripped_text)
        df_classify.at[index, 'category'] = guessed_category
        df_classify.at[index, 'category_source'] = 'guess'

    cols = ['transaction_id', 'category', 'category_source']
    final_df = pd.concat([df_classify[cols], df_train[cols]]).reset_index(drop=True)

    return final_df