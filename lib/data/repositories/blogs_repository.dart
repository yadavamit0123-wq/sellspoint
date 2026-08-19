import 'package:eClassify/data/model/blog/blog.dart';
import 'package:eClassify/data/model/blog/blog_category.dart';
import 'package:eClassify/data/model/blog/blog_tag.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/json_helper.dart';
import 'package:eClassify/utils/log.dart';

class BlogRepository {
  BlogRepository._internal();

  static final BlogRepository _instance = BlogRepository._internal();

  static BlogRepository get instance => _instance;

  Future<List<BlogCategory>> getBlogCategories() async {
    try {
      final response = await Api.get(
        url: Api.blogCategoriesApi,
        // In rare case when blog categories exceed the 100 amount,
        // we need to move from TabBar usage to ListView use-case to leverage
        // pagination or need to provide an additional tab "View More"
        queryParameters: {'per_page': 100},
      );

      return JsonHelper.parseList(
        response['data']?['data'] as List?,
        BlogCategory.fromJson,
      );
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<DataOutput<Blog>> getBlogs({
    int? categoryId,
    String? tag,
    int page = 1,
  }) async {
    try {
      final response = await Api.get(
        url: Api.getBlogApi,
        queryParameters: {
          Api.categoryId: ?categoryId,
          'tag': ?tag,
          Api.page: page,
        },
      );

      final blogs = JsonHelper.parseList(
        response['data']['data'] as List?,
        Blog.fromJson,
      );
      final total = response['data']['total'] as int;

      return DataOutput(total: total, modelList: blogs);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<List<Blog>> getPopularBlogs() async {
    try {
      final response = await Api.get(
        url: Api.popularBlogsApi,
        queryParameters: {'per_page': 4},
      );

      final blogs = JsonHelper.parseList(
        response['data']['data'] as List?,
        Blog.fromJson,
      );

      return blogs;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<Json> getBlogDetails({required int id}) async {
    try {
      final response = await Api.get(
        url: Api.getBlogApi,
        queryParameters: {Api.id: id},
      );

      final blog = JsonHelper.parseObject(
        (response['data']['data'] as List).first,
        Blog.fromJson,
      );

      final relatedBlogs = JsonHelper.parseList(
        response['related_articles'] as List?,
        Blog.fromJson,
      );

      return {'blog': blog, 'related': relatedBlogs};
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<void> addBlogFeedback({
    required int blogId,
    required int? feedback,
  }) async {
    try {
      await Api.post(
        url: Api.blogFeedbackApi,
        parameter: {'blog_id': blogId, 'is_useful': ?feedback},
      );
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<List<BlogTag>> getBlogTags() async {
    try {
      final response = await Api.get(url: Api.blogTagsApi);

      return JsonHelper.parseList(response['data'] as List?, BlogTag.fromJson);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }
}
