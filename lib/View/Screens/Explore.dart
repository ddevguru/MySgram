import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mysgram/View/Screens/Activesearchpage.dart';
import 'package:mysgram/View/Screens/UserProfilePage.dart';
import 'package:mysgram/View/Screens/PostDetailPage.dart';
import 'package:mysgram/services/auth_service.dart';
import 'package:mysgram/Utils/media_utils.dart';
import 'package:mysgram/services/gift_service_simple.dart';

class ExploreController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxList<Map<String, dynamic>> publicPosts = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPublicPosts();
  }

  Future<void> loadPublicPosts() async {
    try {
      isLoading.value = true;
      print('🔍 Loading public posts...');
      
      final result = await AuthService.getPublicPosts();
      print('🔍 Public posts result: $result');
      
      if (result['posts'] != null) {
        final posts = List<Map<String, dynamic>>.from(result['posts']);
        print('🔍 Found ${posts.length} public posts');
        publicPosts.value = posts;
      } else {
        print('❌ No posts in result');
        publicPosts.value = [];
      }
    } catch (e) {
      print('❌ Error loading public posts: $e');
      publicPosts.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void onPostTap(Map<String, dynamic> post) {
    // Navigate to PostDetailPage instead of user profile
    // Get all posts for swipe functionality
    final allPosts = publicPosts.toList();
    final initialIndex = allPosts.indexWhere((p) => p['id'] == post['id']);
    
    if (initialIndex != -1) {
      Get.to(() => PostDetailPage(
        post: post,
        allPosts: allPosts,
        initialIndex: initialIndex,
      ));
    } else {
      // Fallback to user profile if post not found
      Get.to(() => UserProfilePage(userId: post['user_id'].toString()));
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

class Explore extends StatelessWidget {
  const Explore({super.key});

  // Test API connection
  Future<void> _testConnection() async {
    try {
      print('🔍 Testing API connection...');
      final result = await AuthService.testConnection();
      print('✅ API connection test result: $result');
      
      Get.snackbar(
        'API Test',
        'Connection successful! Check console for details.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ API connection test failed: $e');
      Get.snackbar(
        'API Test',
        'Connection failed: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final ExploreController controller = Get.put(ExploreController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.01,
              ),
              child: Container(
                height: height * 0.045,
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(width * 0.05),
                ),
                child: TextField(
                  controller: controller.searchController,
                  onChanged: controller.onSearchChanged,
                  onTap: () => Get.to(Activesearchpage()),
                  style: TextStyle(
                    fontSize: width * 0.04,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: width * 0.04,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                      size: width * 0.05,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: height * 0.01,
                    ),
                  ),
                ),
              ),
            ),

            // Grid Content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.publicPosts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No public posts available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'This could mean:\n• No posts have been created yet\n• All posts are private\n• Database connection issue',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => controller.loadPublicPosts(),
                          child: Text('Refresh'),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _testConnection(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Test API Connection'),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Check console for debugging info',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadPublicPosts,
                  child: _buildStaggeredGrid(controller.publicPosts, width, height, controller),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaggeredGrid(List<Map<String, dynamic>> posts, double width, double height, ExploreController controller) {
    double gap = width * 0.005;
    double itemWidth = (width - (gap * 4)) / 3;
    double smallItemHeight = itemWidth;
    double largeItemHeight = itemWidth * 2 + gap;

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: gap),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: gap,
        mainAxisSpacing: gap,
        childAspectRatio: 1.0,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        bool isLarge = index % 4 == 1; // Make every 4th item large
        
        return Container(
          height: isLarge ? largeItemHeight : smallItemHeight,
          child: _buildGridItem(
            post,
            itemWidth,
            isLarge ? largeItemHeight : smallItemHeight,
            width,
            controller,
          ),
        );
      },
    );
  }



  Widget _buildGridItem(
      Map<String, dynamic> post,
      double itemWidth,
      double itemHeight,
      double width,
      ExploreController controller) {
    return GestureDetector(
      onTap: () => controller.onPostTap(post),
      child: Container(
        width: itemWidth,
        height: itemHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width * 0.025),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(width * 0.025),
          child: MediaUtils.buildMediaWidget(
            url: post['media_url'] ?? '',
            width: itemWidth,
            height: itemHeight,
            fit: BoxFit.cover,
            onTap: () => controller.onPostTap(post),
            autoPlay: true, // Enable auto-play for videos in grid view
          ),
        ),
      ),
    );
  }
}
